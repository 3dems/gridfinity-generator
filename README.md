# Gridfinity Drawer & Base for PrusaSlicer

Official PrusaSlicer 3.0+ plugin developed by **3DEMS**. Procedurally generate custom-fitted modular Gridfinity baseplates, smart drawer gap-filler spacers, and stackable bins tailored to your drawer and 3D printer bed dimensions.

---

## 🌟 The Problem It Solves

Standard Gridfinity baseplates rarely fit real-world drawers perfectly. Drawers almost never have inner dimensions that are exact multiples of the 42 mm Gridfinity unit. When placing generic grids inside:
* Baseplates slide, wobble, and rattle whenever the drawer is opened or closed.
* Dead, unsightly gaps are left around the perimeter edges.
* Large drawers (e.g., $420 \times 420\text{ mm}$) produce monolithic blocks that exceed standard 3D printer build plates.

**Gridfinity Drawer & Base** solves every single one of these issues automatically in seconds:
1. **Drawer Matrix Math**: Computes the optimal $N_x \times N_y$ cell matrix and calculates remaining millimeter gaps with precision.
2. **Intelligent Multi-Bed Partitioning**: Automatically detects your active PrusaSlicer printer (**CORE One**, **MK4/MK3**, **XL**, or **MINI**) and partitions oversized drawer grids into balanced, modular interlocking tiles that fit your build plate.
3. **Integrated Gap Fillers**: Exterior tiles seamlessly integrate solid border spacers (or utility tool troughs) so the entire assembly locks securely inside your drawer without screws or glue.
4. **Stackable Bins**: Generate matching Gridfinity bins with genuine stepped bottom feet and magnet sockets resting flat on the print bed ($Z \ge 0$).

---

## 🚀 Key Features

* **🖨️ Multi-Bed & Printer-Aware Tiling**:
  * **Prusa CORE One / One+** ($250 \times 220\text{ mm}$): Max $5 \times 5$ cells per tile ($210 \times 210\text{ mm}$).
  * **Prusa MK4 / MK4S / MK3.9 / MK3S+** ($250 \times 210\text{ mm}$): Balanced $5 \times 4$ cells per tile.
  * **Prusa XL** ($360 \times 360\text{ mm}$): High-capacity tiles up to $8 \times 8$ cells ($336 \times 336\text{ mm}$).
  * **Prusa MINI / MINI+** ($180 \times 180\text{ mm}$): Compact $4 \times 4$ tiles ($168 \times 168\text{ mm}$).
* **🧩 Independent Plater Objects**: Each tile is added as its own object in PrusaSlicer. Use PrusaSlicer's Auto-arrange (`A`) or assign tiles across multiple print beds.
* **🧲 Official Gridfinity Standard**: Standard 4.8 mm baseplate height with 3.4 mm divider walls, corner retention lugs, and $6.5\text{ mm}$ holes for $6\times 2\text{ mm}$ neodymium magnets spaced at 26 mm.
* **📦 Parametric Stackable Bins**: Generate matching Gridfinity bins ($1\times 1$, $1\times 2$, $2\times 2$, $3\times 3$, etc.) from 2U ($14\text{ mm}$) to 12U ($84\text{ mm}$) with sculpted feet and bottom magnet sockets resting flush on the print bed ($Z \ge 0$).
* **🛠️ Utility Gap Troughs**: Turn dead space at the back of the drawer into long horizontal trays for calipers, pens, rulers, or screwdrivers.
* **⚡ 100% Native In-Memory**: Instant zero-CAD generation directly onto the build plate without external dependencies.

---

## 📖 Quickstart Guide

1. Open PrusaSlicer and select the **Plater** tab.
2. From the top menu, choose **3DEMS** $\rightarrow$ **Gridfinity Drawer & Base**.
3. Enter your drawer's interior width and depth (e.g. `420` $\times$ `420` mm).
4. Choose your printer profile (or leave on **Auto-detect**).
5. Click **OK** $\rightarrow$ Ready-to-slice modular tiles appear on the build plate!

---

## Standard & Attribution
Based on the open-source **Gridfinity** modular storage specification created by **Zack Freedman (Voidstar Lab)** under the **MIT License**.

## Author & Marketplace
* **Author**: [3DEMS](https://github.com/3dems)
* **Author ID**: `9d2f6477-ddc2-4189-b873-d0026dd7a4ef`
* **Plugin ID**: `io.github.3dems.gridfinity-generator`
* **License**: AGPL-3.0-only
