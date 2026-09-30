/* steamshim.cpp - ludic.steamworks's hand-written native half: everything the generated
   wrappers (gen/lsg_wrap.cpp) cannot be, because it is not one call with plain types.

   It follows the shape every shim in packages/ has (packages/README.md, "Native libraries"):
   int, long, float, strings and opaque pointers cross; nothing calls back into Ludic. What Steam
   reports through a callback or a call result is decoded here into a fixed ring of facts that the
   package drains after each pump, so a frame allocates nothing.

   It includes the Steamworks SDK's own headers from the developer's machine (-I $STEAMWORKS_SDK/public)
   and contains none of Valve's text: only calls and field names, which is what a binding says. */
#include <stdint.h>
#include <string.h>
#include <stdio.h>
#include "steam/steam_api_flat.h"

#if defined(_WIN32)
#define LSX_API extern "C" __declspec(dllexport)
#else
#define LSX_API extern "C" __attribute__((visibility("default")))
#endif

/* set once the API is initialised; every generated wrapper answers a default until then */
extern "C" int lsx_ready = 0;

static HSteamPipe s_pipe = 0;
static char s_err[1024];

/* ---- a string for Ludic: copied into a small ring, valid until the ring comes round ---- */
extern "C" const char *lsg_str(const char *s) {
  static char ring[8][2048];
  static int at = 0;
  char *b = ring[at];
  at = (at + 1) & 7;
  if (!s) { b[0] = 0; return b; }
  size_t n = strlen(s);
  if (n > 2047) n = 2047;
  memcpy(b, s, n);
  b[n] = 0;
  return b;
}

/* ---- facts: the kinds are the package's (LSX_* here, STF_* in Ludic) ---- */
enum {
  F_CONNECTED = 1, F_DISCONNECTED = 2, F_SHUTDOWN = 3, F_PERSONA = 4, F_AVATAR = 5, F_OVERLAY = 6,
  F_JOIN_REQUEST = 7, F_LOBBY_JOIN_REQUEST = 8, F_LOBBY_CREATED = 9, F_LOBBY_ENTERED = 10,
  F_LOBBY_MEMBER = 11, F_LOBBY_DATA = 12, F_LOBBY_CHAT = 13, F_LOBBY_KICKED = 14, F_LOBBY_LIST = 15,
  F_STATS_RECEIVED = 16, F_STATS_STORED = 17, F_ACH_STORED = 18, F_LB_FOUND = 19, F_LB_UPLOADED = 20,
  F_LB_DOWNLOADED = 21, F_DLC_INSTALLED = 22, F_URL_LAUNCH = 23, F_GAMEPAD_TEXT = 24,
  F_NET_SESSION_REQUEST = 25, F_NET_SESSION_FAILED = 26, F_PRESENCE = 27, F_CALL_FAILED = 28,
  F_CONNECT_FAILED = 29
};

#define FACT_RING 256
#define FACT_TEXT 1024
struct Fact {
  int kind;
  int i[4];
  int64_t l[2];
  char text[FACT_TEXT];
};
static Fact s_ring[FACT_RING];
static int s_head = 0, s_count = 0, s_lost = 0;
static Fact s_cur;

static Fact *push(int kind) {
  if (s_count >= FACT_RING) { s_lost++; return 0; }
  Fact *f = &s_ring[(s_head + s_count) % FACT_RING];
  s_count++;
  memset(f, 0, sizeof(Fact));
  f->kind = kind;
  return f;
}

static void set_text(Fact *f, const char *s) {
  if (!f || !s) return;
  size_t n = strlen(s);
  if (n >= FACT_TEXT) n = FACT_TEXT - 1;
  memcpy(f->text, s, n);
  f->text[n] = 0;
}

/* the next fact becomes the current one; its kind, or 0 when there is none */
LSX_API int lsx_poll(void) {
  if (s_count == 0) return 0;
  s_cur = s_ring[s_head];
  s_head = (s_head + 1) % FACT_RING;
  s_count--;
  return s_cur.kind;
}
LSX_API int lsx_fi(int k) { return (k >= 0 && k < 4) ? s_cur.i[k] : 0; }
LSX_API int64_t lsx_fl(int k) { return (k >= 0 && k < 2) ? s_cur.l[k] : 0; }
LSX_API int lsx_ftext(char *buf, int cap) {
  int n = (int)strlen(s_cur.text);
  if (cap <= 0) return n;
  if (n >= cap) n = cap - 1;
  memcpy(buf, s_cur.text, n);
  buf[n] = 0;
  return n;
}
LSX_API int lsx_lost(void) { return s_lost; }

/* ---- Steam Networking Messages: the peers the package has allowed may open a session ---- */
#define ALLOWED_MAX 128
static uint64 s_allowed[ALLOWED_MAX];
static int s_allowed_n = 0;
static int s_accept_any = 0;

LSX_API void lsx_net_allow(int64_t id) {
  for (int i = 0; i < s_allowed_n; i++) if (s_allowed[i] == (uint64)id) return;
  if (s_allowed_n < ALLOWED_MAX) s_allowed[s_allowed_n++] = (uint64)id;
}
LSX_API void lsx_net_accept_any(int on) { s_accept_any = on; }

static bool net_allowed(uint64 id) {
  if (s_accept_any) return true;
  for (int i = 0; i < s_allowed_n; i++) if (s_allowed[i] == id) return true;
  return false;
}

/* ---- leaderboard entries of the last download, read by index ---- */
#define LB_MAX 128
static int64_t s_lb_user[LB_MAX];
static int s_lb_score[LB_MAX], s_lb_rank[LB_MAX];
static int s_lb_n = 0;

/* ---- decode one callback or call result into a fact ---- */
static void decode(int id, void *p, int size, bool from_call) {
  (void)size;
  switch (id) {
    case SteamServersConnected_t::k_iCallback: push(F_CONNECTED); break;
    case SteamServersDisconnected_t::k_iCallback: {
      Fact *f = push(F_DISCONNECTED);
      if (f) f->i[0] = (int)((SteamServersDisconnected_t *)p)->m_eResult;
      break;
    }
    case SteamServerConnectFailure_t::k_iCallback: {
      Fact *f = push(F_CONNECT_FAILED);
      if (f) { f->i[0] = (int)((SteamServerConnectFailure_t *)p)->m_eResult; f->i[1] = ((SteamServerConnectFailure_t *)p)->m_bStillRetrying ? 1 : 0; }
      break;
    }
    case SteamShutdown_t::k_iCallback: push(F_SHUTDOWN); break;
    case PersonaStateChange_t::k_iCallback: {
      PersonaStateChange_t *c = (PersonaStateChange_t *)p;
      Fact *f = push(F_PERSONA);
      if (f) { f->l[0] = (int64_t)c->m_ulSteamID; f->i[0] = c->m_nChangeFlags; }
      break;
    }
    case AvatarImageLoaded_t::k_iCallback: {
      AvatarImageLoaded_t *c = (AvatarImageLoaded_t *)p;
      Fact *f = push(F_AVATAR);
      if (f) { f->l[0] = (int64_t)c->m_steamID.ConvertToUint64(); f->i[0] = c->m_iImage; f->i[1] = c->m_iWide; f->i[2] = c->m_iTall; }
      break;
    }
    case GameOverlayActivated_t::k_iCallback: {
      Fact *f = push(F_OVERLAY);
      if (f) f->i[0] = ((GameOverlayActivated_t *)p)->m_bActive ? 1 : 0;
      break;
    }
    case GameRichPresenceJoinRequested_t::k_iCallback: {
      GameRichPresenceJoinRequested_t *c = (GameRichPresenceJoinRequested_t *)p;
      Fact *f = push(F_JOIN_REQUEST);
      if (f) { f->l[0] = (int64_t)c->m_steamIDFriend.ConvertToUint64(); set_text(f, c->m_rgchConnect); }
      break;
    }
    case GameLobbyJoinRequested_t::k_iCallback: {
      GameLobbyJoinRequested_t *c = (GameLobbyJoinRequested_t *)p;
      Fact *f = push(F_LOBBY_JOIN_REQUEST);
      if (f) { f->l[0] = (int64_t)c->m_steamIDLobby.ConvertToUint64(); f->l[1] = (int64_t)c->m_steamIDFriend.ConvertToUint64(); }
      break;
    }
    case LobbyCreated_t::k_iCallback: {
      LobbyCreated_t *c = (LobbyCreated_t *)p;
      Fact *f = push(F_LOBBY_CREATED);
      if (f) { f->i[0] = (int)c->m_eResult; f->l[0] = (int64_t)c->m_ulSteamIDLobby; }
      break;
    }
    case LobbyEnter_t::k_iCallback: {
      LobbyEnter_t *c = (LobbyEnter_t *)p;
      Fact *f = push(F_LOBBY_ENTERED);
      if (f) { f->l[0] = (int64_t)c->m_ulSteamIDLobby; f->i[0] = (int)c->m_EChatRoomEnterResponse; f->i[1] = c->m_bLocked ? 1 : 0; f->i[2] = (int)c->m_rgfChatPermissions; }
      break;
    }
    case LobbyChatUpdate_t::k_iCallback: {
      LobbyChatUpdate_t *c = (LobbyChatUpdate_t *)p;
      Fact *f = push(F_LOBBY_MEMBER);
      if (f) { f->l[0] = (int64_t)c->m_ulSteamIDLobby; f->l[1] = (int64_t)c->m_ulSteamIDUserChanged; f->i[0] = (int)c->m_rgfChatMemberStateChange; }
      break;
    }
    case LobbyDataUpdate_t::k_iCallback: {
      LobbyDataUpdate_t *c = (LobbyDataUpdate_t *)p;
      Fact *f = push(F_LOBBY_DATA);
      if (f) { f->l[0] = (int64_t)c->m_ulSteamIDLobby; f->l[1] = (int64_t)c->m_ulSteamIDMember; f->i[0] = c->m_bSuccess ? 1 : 0; }
      break;
    }
    case LobbyChatMsg_t::k_iCallback: {
      LobbyChatMsg_t *c = (LobbyChatMsg_t *)p;
      Fact *f = push(F_LOBBY_CHAT);
      if (f) {
        CSteamID who;
        EChatEntryType type = k_EChatEntryTypeInvalid;
        char text[FACT_TEXT];
        int n = SteamMatchmaking()->GetLobbyChatEntry(CSteamID((uint64)c->m_ulSteamIDLobby), (int)c->m_iChatID, &who, text, FACT_TEXT - 1, &type);
        if (n < 0) n = 0;
        if (n > FACT_TEXT - 1) n = FACT_TEXT - 1;
        text[n] = 0;
        f->l[0] = (int64_t)c->m_ulSteamIDLobby;
        f->l[1] = (int64_t)who.ConvertToUint64();
        f->i[0] = (int)type;
        set_text(f, text);
      }
      break;
    }
    case LobbyKicked_t::k_iCallback: {
      LobbyKicked_t *c = (LobbyKicked_t *)p;
      Fact *f = push(F_LOBBY_KICKED);
      if (f) { f->l[0] = (int64_t)c->m_ulSteamIDLobby; f->i[0] = c->m_bKickedDueToDisconnect ? 1 : 0; }
      break;
    }
    case LobbyMatchList_t::k_iCallback: {
      Fact *f = push(F_LOBBY_LIST);
      if (f) f->i[0] = (int)((LobbyMatchList_t *)p)->m_nLobbiesMatching;
      break;
    }
    case UserStatsReceived_t::k_iCallback: {
      UserStatsReceived_t *c = (UserStatsReceived_t *)p;
      Fact *f = push(F_STATS_RECEIVED);
      if (f) { f->i[0] = (int)c->m_eResult; f->l[0] = (int64_t)c->m_steamIDUser.ConvertToUint64(); }
      break;
    }
    case UserStatsStored_t::k_iCallback: {
      Fact *f = push(F_STATS_STORED);
      if (f) f->i[0] = (int)((UserStatsStored_t *)p)->m_eResult;
      break;
    }
    case UserAchievementStored_t::k_iCallback: {
      UserAchievementStored_t *c = (UserAchievementStored_t *)p;
      Fact *f = push(F_ACH_STORED);
      if (f) { f->i[0] = (int)c->m_nCurProgress; f->i[1] = (int)c->m_nMaxProgress; set_text(f, c->m_rgchAchievementName); }
      break;
    }
    case LeaderboardFindResult_t::k_iCallback: {
      LeaderboardFindResult_t *c = (LeaderboardFindResult_t *)p;
      Fact *f = push(F_LB_FOUND);
      if (f) { f->l[0] = (int64_t)c->m_hSteamLeaderboard; f->i[0] = c->m_bLeaderboardFound ? 1 : 0; }
      break;
    }
    case LeaderboardScoreUploaded_t::k_iCallback: {
      LeaderboardScoreUploaded_t *c = (LeaderboardScoreUploaded_t *)p;
      Fact *f = push(F_LB_UPLOADED);
      if (f) { f->l[0] = (int64_t)c->m_hSteamLeaderboard; f->i[0] = c->m_bSuccess ? 1 : 0; f->i[1] = c->m_nScore; f->i[2] = c->m_bScoreChanged ? 1 : 0; f->i[3] = c->m_nGlobalRankNew; }
      break;
    }
    case LeaderboardScoresDownloaded_t::k_iCallback: {
      LeaderboardScoresDownloaded_t *c = (LeaderboardScoresDownloaded_t *)p;
      int n = c->m_cEntryCount;
      if (n > LB_MAX) n = LB_MAX;
      s_lb_n = 0;
      for (int k = 0; k < n; k++) {
        LeaderboardEntry_t e;
        if (SteamUserStats()->GetDownloadedLeaderboardEntry(c->m_hSteamLeaderboardEntries, k, &e, 0, 0)) {
          s_lb_user[s_lb_n] = (int64_t)e.m_steamIDUser.ConvertToUint64();
          s_lb_score[s_lb_n] = e.m_nScore;
          s_lb_rank[s_lb_n] = e.m_nGlobalRank;
          s_lb_n++;
        }
      }
      Fact *f = push(F_LB_DOWNLOADED);
      if (f) { f->l[0] = (int64_t)c->m_hSteamLeaderboard; f->i[0] = s_lb_n; }
      break;
    }
    case DlcInstalled_t::k_iCallback: {
      Fact *f = push(F_DLC_INSTALLED);
      if (f) f->i[0] = (int)((DlcInstalled_t *)p)->m_nAppID;
      break;
    }
    case NewUrlLaunchParameters_t::k_iCallback: push(F_URL_LAUNCH); break;
    case GamepadTextInputDismissed_t::k_iCallback: {
      GamepadTextInputDismissed_t *c = (GamepadTextInputDismissed_t *)p;
      Fact *f = push(F_GAMEPAD_TEXT);
      if (f) {
        f->i[0] = c->m_bSubmitted ? 1 : 0;
        f->i[1] = (int)c->m_unSubmittedText;
        if (c->m_bSubmitted) {
          char text[FACT_TEXT];
          if (SteamUtils()->GetEnteredGamepadTextInput(text, FACT_TEXT)) set_text(f, text);
        }
      }
      break;
    }
    case FriendRichPresenceUpdate_t::k_iCallback: {
      Fact *f = push(F_PRESENCE);
      if (f) f->l[0] = (int64_t)((FriendRichPresenceUpdate_t *)p)->m_steamIDFriend.ConvertToUint64();
      break;
    }
    case SteamNetworkingMessagesSessionRequest_t::k_iCallback: {
      SteamNetworkingMessagesSessionRequest_t *c = (SteamNetworkingMessagesSessionRequest_t *)p;
      uint64 who = c->m_identityRemote.GetSteamID64();
      bool ok = who != 0 && net_allowed(who);
      if (ok) SteamNetworkingMessages()->AcceptSessionWithUser(c->m_identityRemote);
      Fact *f = push(F_NET_SESSION_REQUEST);
      if (f) { f->l[0] = (int64_t)who; f->i[0] = ok ? 1 : 0; }
      break;
    }
    case SteamNetworkingMessagesSessionFailed_t::k_iCallback: {
      SteamNetworkingMessagesSessionFailed_t *c = (SteamNetworkingMessagesSessionFailed_t *)p;
      Fact *f = push(F_NET_SESSION_FAILED);
      if (f) { f->l[0] = (int64_t)c->m_info.m_identityRemote.GetSteamID64(); f->i[0] = (int)c->m_info.m_eEndReason; }
      break;
    }
    default:
      (void)from_call;
      break;
  }
}

/* ---- lifecycle ---- */

/* 0 ok; 1 failed; 2 no Steam client; 3 client out of date; 4 launched outside Steam (the game should
   quit: Steam starts it again). `dev` skips the relaunch check: a development run has steam_appid.txt. */
LSX_API int lsx_init(int app_id, int dev) {
  s_err[0] = 0;
  if (lsx_ready) return 0;
  if (!dev && app_id > 0 && SteamAPI_RestartAppIfNecessary((uint32)app_id)) return 4;
  SteamErrMsg err;
  err[0] = 0;
  ESteamAPIInitResult r = SteamAPI_InitFlat(&err);
  if (r != k_ESteamAPIInitResult_OK) {
    strncpy(s_err, err, sizeof(s_err) - 1);
    s_err[sizeof(s_err) - 1] = 0;
    if (r == k_ESteamAPIInitResult_NoSteamClient) return 2;
    if (r == k_ESteamAPIInitResult_VersionMismatch) return 3;
    return 1;
  }
  SteamAPI_ManualDispatch_Init();
  s_pipe = SteamAPI_GetHSteamPipe();
  s_head = s_count = 0;
  lsx_ready = 1;
  return 0;
}

LSX_API int lsx_error(char *buf, int cap) {
  int n = (int)strlen(s_err);
  if (cap <= 0) return n;
  if (n >= cap) n = cap - 1;
  memcpy(buf, s_err, n);
  buf[n] = 0;
  return n;
}

LSX_API void lsx_shutdown(void) {
  if (!lsx_ready) return;
  lsx_ready = 0;
  SteamAPI_Shutdown();
  s_pipe = 0;
  s_count = 0;
}

/* run the callbacks and call results that came in, into facts */
LSX_API void lsx_pump(void) {
  if (!lsx_ready) return;
  static unsigned char result[8192];
  SteamAPI_ManualDispatch_RunFrame(s_pipe);
  CallbackMsg_t msg;
  while (SteamAPI_ManualDispatch_GetNextCallback(s_pipe, &msg)) {
    if (msg.m_iCallback == SteamAPICallCompleted_t::k_iCallback) {
      SteamAPICallCompleted_t *done = (SteamAPICallCompleted_t *)msg.m_pubParam;
      if (done->m_cubParam > 0 && done->m_cubParam <= (int)sizeof(result)) {
        bool failed = false;
        if (SteamAPI_ManualDispatch_GetAPICallResult(s_pipe, done->m_hAsyncCall, result, done->m_cubParam, done->m_iCallback, &failed) && !failed) {
          decode(done->m_iCallback, result, done->m_cubParam, true);
        } else {
          Fact *f = push(F_CALL_FAILED);
          if (f) f->i[0] = done->m_iCallback;
        }
      }
    } else {
      decode(msg.m_iCallback, msg.m_pubParam, msg.m_cubParam, false);
    }
    SteamAPI_ManualDispatch_FreeLastCallback(s_pipe);
  }
}

/* ---- friends: the game a friend is in, read in two steps (the struct stays here) ---- */
static int64_t s_fg_game = 0, s_fg_lobby = 0;
LSX_API int lsx_friend_game(int64_t id) {
  if (!lsx_ready) return 0;
  FriendGameInfo_t g;
  if (!SteamFriends()->GetFriendGamePlayed(CSteamID((uint64)id), &g)) return 0;
  s_fg_game = (int64_t)g.m_gameID.ToUint64();
  s_fg_lobby = (int64_t)g.m_steamIDLobby.ConvertToUint64();
  return 1;
}
LSX_API int64_t lsx_friend_game_id(void) { return s_fg_game; }
LSX_API int64_t lsx_friend_game_lobby(void) { return s_fg_lobby; }

/* ---- leaderboards: the entries of the last download ---- */
LSX_API int lsx_lb_count(void) { return s_lb_n; }
LSX_API int64_t lsx_lb_user(int i) { return (i >= 0 && i < s_lb_n) ? s_lb_user[i] : 0; }
LSX_API int lsx_lb_score(int i) { return (i >= 0 && i < s_lb_n) ? s_lb_score[i] : 0; }
LSX_API int lsx_lb_rank(int i) { return (i >= 0 && i < s_lb_n) ? s_lb_rank[i] : 0; }

/* ---- Steam Input: the action data comes back as a struct, so it is read here ---- */
static InputHandle_t s_ctrl[STEAM_INPUT_MAX_COUNT];
static int s_ctrl_n = 0;
LSX_API int lsx_input_controllers(void) {
  if (!lsx_ready) return 0;
  s_ctrl_n = SteamInput()->GetConnectedControllers(s_ctrl);
  return s_ctrl_n;
}
LSX_API int64_t lsx_input_controller(int i) { return (i >= 0 && i < s_ctrl_n) ? (int64_t)s_ctrl[i] : 0; }
/* bit 0: down, bit 1: the action is active in the set that is on */
LSX_API int lsx_input_digital(int64_t controller, int64_t action) {
  if (!lsx_ready) return 0;
  InputDigitalActionData_t d = SteamInput()->GetDigitalActionData((InputHandle_t)controller, (InputDigitalActionHandle_t)action);
  return (d.bState ? 1 : 0) | (d.bActive ? 2 : 0);
}
/* xy[0], xy[1]; the return is 1 when the action is active */
LSX_API int lsx_input_analog(int64_t controller, int64_t action, float *xy) {
  if (!lsx_ready) return 0;
  InputAnalogActionData_t d = SteamInput()->GetAnalogActionData((InputHandle_t)controller, (InputAnalogActionHandle_t)action);
  xy[0] = d.x;
  xy[1] = d.y;
  return d.bActive ? 1 : 0;
}

/* ---- Steam Networking Messages: a datagram to a user, through Steam's relay ---- */
LSX_API void lsx_net_start(void) {
  if (!lsx_ready) return;
  SteamNetworkingUtils()->InitRelayNetworkAccess();
}
/* 1 when the message was taken (sent, or queued for a session that is opening) */
LSX_API int lsx_net_send(int64_t to, const void *data, int n, int reliable, int channel) {
  if (!lsx_ready || to == 0 || n < 0) return 0;
  SteamNetworkingIdentity who;
  who.SetSteamID64((uint64)to);
  int flags = k_nSteamNetworkingSend_AutoRestartBrokenSession;
  flags |= reliable ? k_nSteamNetworkingSend_Reliable : k_nSteamNetworkingSend_UnreliableNoNagle;
  return SteamNetworkingMessages()->SendMessageToUser(who, data, (uint32)n, flags, channel) == k_EResultOK ? 1 : 0;
}
static int64_t s_net_from = 0;
/* the next message on the channel, copied into buf (cut to cap); its length, or -1 when none */
LSX_API int lsx_net_recv(void *buf, int cap, int channel) {
  if (!lsx_ready) return -1;
  SteamNetworkingMessage_t *m = 0;
  int got = SteamNetworkingMessages()->ReceiveMessagesOnChannel(channel, &m, 1);
  if (got <= 0 || !m) return -1;
  int n = (int)m->m_cbSize;
  if (n > cap) n = cap;
  memcpy(buf, m->m_pData, n);
  s_net_from = (int64_t)m->m_identityPeer.GetSteamID64();
  m->Release();
  return n;
}
LSX_API int64_t lsx_net_from(void) { return s_net_from; }
LSX_API void lsx_net_close(int64_t who) {
  if (!lsx_ready) return;
  SteamNetworkingIdentity id;
  id.SetSteamID64((uint64)who);
  SteamNetworkingMessages()->CloseSessionWithUser(id);
}
