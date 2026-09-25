---
id: kw-state
name: state
category: control
kind: keyword
tokens: state
sig: state Name { … }
tip: One state of a machine — its body runs while the machine sits in it.
order: 7
---

A <code>state</code> declares one state of an enclosing <code>machine</code>: a named block whose body runs while the machine's store holds that state's value. States take their value from declaration order — the first `state` is `0`, the next `1`, and so on — so you refer to them by name and never track the numbers yourself (write `state Name = expr` only when a state must have a specific value). From inside a state, `become OtherName` transitions the machine by storing the target state's value back into the store. Keep each state focused on the logic for that mode and hand off with `become` when its condition to move on is met.

```ludic
program DoorControl {
  enum DoorState { Closed, Opening, Open }
  state DoorControlState {
    door: int = DoorState.Closed
    elapsed_frames: int = 0
  }

  handler RunDoor(door_control_st: mut DoorControlState) phase Update {
    machine door_control_st.door {
      state Closed {
        if Input.key() == ' ' { door_control_st.elapsed_frames = 0; become Opening }
      }
      state Opening {
        door_control_st.elapsed_frames = door_control_st.elapsed_frames + 1
        if door_control_st.elapsed_frames >= 30 { become Open }
      }
      state Open {
        Screen.status("door open")
      }
    }
  }
}
```
