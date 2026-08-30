#!/usr/bin/env python3
"""Create a Forgejo release and attach build artifacts.

    forgejo_release.py <tag> <body-file> <assets-dir>

Reads the access token from $FORGEJO_TOKEN. `x release --publish` calls this
after it has pushed the tag; it is the one piece of the release flow that speaks
HTTP, which the Ludic task runner cannot do yet (a native Http client is issue
#6). Python stdlib only — no third-party deps — matching the docgen tooling.

Idempotent-ish: if the release for <tag> already exists it is reused, and each
asset in <assets-dir> is uploaded (a duplicate name is skipped, not fatal).
"""
import json
import os
import sys
import urllib.request
import urllib.error

API = "https://git.workshopsoft.io/api/v1/repos/workshopsoft/ludic"


def token():
    t = os.environ.get("FORGEJO_TOKEN", "").strip()
    if not t:
        sys.exit("forgejo_release: FORGEJO_TOKEN is not set")
    return t


def api(method, path, tok, data=None, headers=None, raw=False):
    url = API + path
    h = {"Authorization": "token " + tok}
    body = None
    if data is not None and not raw:
        h["Content-Type"] = "application/json"
        body = json.dumps(data).encode()
    elif raw:
        body = data
        h.update(headers or {})
    req = urllib.request.Request(url, data=body, headers=h, method=method)
    with urllib.request.urlopen(req) as r:
        return r.getcode(), json.loads(r.read().decode() or "null")


def get_release_by_tag(tag, tok):
    try:
        _, rel = api("GET", "/releases/tags/" + tag, tok)
        return rel
    except urllib.error.HTTPError as e:
        if e.code == 404:
            return None
        raise


def main():
    if len(sys.argv) != 4:
        sys.exit(__doc__)
    tag, body_file, assets_dir = sys.argv[1], sys.argv[2], sys.argv[3]
    tok = token()

    body = ""
    if os.path.exists(body_file):
        with open(body_file, encoding="utf-8") as fh:
            body = fh.read()

    rel = get_release_by_tag(tag, tok)
    if rel is None:
        _, rel = api("POST", "/releases", tok, {
            "tag_name": tag,
            "name": tag,
            "body": body,
            "draft": False,
            "prerelease": tag.startswith("v0."),
        })
        print("created release", tag, "id", rel["id"])
    else:
        print("release", tag, "already exists (id %s); uploading assets" % rel["id"])

    rid = rel["id"]
    existing = {a["name"] for a in (rel.get("assets") or [])}
    if os.path.isdir(assets_dir):
        for name in sorted(os.listdir(assets_dir)):
            if name in existing:
                print("  skip (exists):", name)
                continue
            path = os.path.join(assets_dir, name)
            if not os.path.isfile(path):
                continue
            with open(path, "rb") as fh:
                blob = fh.read()
            boundary = "----ludicrelease7f3b2a"
            payload = (
                ("--%s\r\n" % boundary)
                + ('Content-Disposition: form-data; name="attachment"; filename="%s"\r\n' % name)
                + "Content-Type: application/octet-stream\r\n\r\n"
            ).encode() + blob + ("\r\n--%s--\r\n" % boundary).encode()
            code, _ = api(
                "POST", "/releases/%s/assets?name=%s" % (rid, name), tok,
                data=payload, raw=True,
                headers={"Content-Type": "multipart/form-data; boundary=" + boundary},
            )
            print("  uploaded:", name, "(HTTP %d)" % code)
    print("done:", API + "/releases/tag/" + tag)


if __name__ == "__main__":
    main()
