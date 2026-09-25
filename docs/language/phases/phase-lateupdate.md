---
id: phase-lateupdate
name: LateUpdate
category: phases
kind: phase
tokens: LateUpdate
sig: phase LateUpdate
tip: Runs each frame after Update and before Render.
order: 4
---

<code>LateUpdate</code> runs once per frame, after every <code>Update</code> handler has finished and just before <code>Render</code>. Use it for logic that must observe the <b>settled</b> result of this frame's updates: following the camera to the player's new position, resolving queued despawns, or any end-of-step cleanup that would be wrong to do while other <code>Update</code> handlers are still moving models. The full per-frame order the engine runs is <code>Input</code> → <code>FixedUpdate</code> → <code>Update</code> → <code>LateUpdate</code> → <code>Render</code>, with <code>Start</code> running once at boot before any of them.

```ludic
program FollowCamera {
  property Position { column: int = 0, row: int = 0 }
  model Player { Position }

  state FollowCameraState {
    camera_column: int = 0
  }

  handler SpawnPlayer phase Start {
    spawn Player { Position { column: 12, row: 0 } }
  }

  @Queries(these: [Position])
  handler MovePlayer phase Update {
    Position.column = Position.column + 1
  }

  # runs after MovePlayer, so the camera sees the final position
  @Queries(these: [Position])
  handler TrackPlayer(follow_camera_st: mut FollowCameraState) phase LateUpdate {
    follow_camera_st.camera_column = Position.column
  }
}
```
