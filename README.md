# Gridfinity Drawer Optimizer & Gap Filler for PrusaSlicer

Official PrusaSlicer 3.0+ plugin developed by **3DEMS** to optimize drawers with custom-fitted Gridfinity modular storage baseplates and gap-filler spacers.

## The Problem It Solves
Real-world drawers almost never have dimensions that are exact multiples of 42 mm. When placing standard Gridfinity grids in a drawer:
- The baseplates slide and rattle around when opening and closing the drawer.
- Unsightly, wasted dead space ("gaps") are left around the edges.

## Features
- **Smart Drawer Math**: Input your drawer's exact inner width and depth; the plugin calculates the maximum Gridfinity grid ($N_x \times N_y$) and the exact remaining gap.
- **Custom Gap Distribution**:
  - **Centered**: Evenly divides the remaining space on both sides / front and back.
  - **Flush Front**: Pushes the entire grid to the front of the drawer, placing all filler space at the back.
  - **Flush Left/Right**: Pushes the grid against the desired sidewall.
- **Gap Treatment Options**:
  - **Solid Fitted Border**: A clean spacer perimeter that hugs the drawer walls snugly to lock the grid in place.
  - **Utility Storage Trough**: Converts large remaining gaps (e.g. at the back or side) into functional long troughs for rulers, calipers, pens, or screwdrivers.
  - **Standalone Gap Filler Strips**: Generates only the filler blocks to retrofit existing printed Gridfinity baseplates.
- **100% Native In-Memory Generation**: Zero disk I/O, lightning-fast generation directly onto the build plate.

## Standard & Attribution
Based on the open-source **Gridfinity** modular storage system created by **Zack Freedman (Voidstar Lab)** released under the **MIT License**.

## Author & Marketplace
- **Author ID**: `9d2f6477-ddc2-4189-b873-d0026dd7a4ef`
- **Plugin ID**: `io.github.3dems.gridfinity-generator`

## License
AGPL-3.0-only
