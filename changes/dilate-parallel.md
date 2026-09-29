bump: patch
type: performance
**Cut-out edge padding runs on every core.** `tex_dilate`'s passes hand their rows, sixteen at a time, to
`Job.parallel_for`: within a pass a row writes only its own still-masked texels and reads only
neighbours the mask already let go, so the bytes are the ones the single-threaded loop made. The worker
is handed plain buffers in a `DilateJob` and makes nothing. `tex_dilate_bytes` is the slice-taking
form (safe_api.ludic), and `examples/rendering/dilate.ludic` holds the result against the old loop
(prints DILATE OK). It was 206 ms of the main thread in a Maroon Lake boot.
