bump: patch
type: feat
Things sit ON the ground rather than hovering over it. The screen-space GI pass takes
a second, much tighter set of taps (a 0.40 m radius that grows with distance, with a
range check so a far surface behind a near one cannot darken it) and folds the result
into the ambient occlusion it already had. The wide radius answers "how enclosed is
this", which a trunk meeting grass barely registers; the tight one answers "is
something touching here", which is the shadow the eye looks for to place an object.
It is eight taps on a buffer the pass had already bound.
