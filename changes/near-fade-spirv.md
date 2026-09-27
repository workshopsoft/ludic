bump: patch
type: fix
**The foliage's near-fade programs have SPIR-V.** The three `NEAR_FADE` variants were missing
from `variants.list`, so on Vulkan the trees' and cards' programs failed to build.
