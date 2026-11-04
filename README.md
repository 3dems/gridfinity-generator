# Gridfinity Drawer & Base for PrusaSlicer

Official PrusaSlicer 3.0+ plugin developed by **3DEMS**. Generate custom-fitted modular Gridfinity baseplates, smart drawer gap-filler spacers, and stackable bins tailored to your drawer and printer bed dimensions.

---

## 🌟 Why This Plugin?

Real-world drawers are almost never exact multiples of the 42 mm Gridfinity standard. Placing standard grids leaves unsightly dead zones, causing baseplates and bins to slide and rattle when drawers open.

**Gridfinity Drawer & Base** solves this automatically:
1. **Measures your drawer**: Computes the optimal $N_x \times N_y$ cell matrix and exact remaining millimeter gaps.
2. **Auto-splits for your 3D printer**: If your drawer is larger than your print bed (e.g. $420 \times 420\text{ mm}$), the plugin detects your active printer (**CORE One**, **MK4/MK3**, **XL**, or **MINI**) and automatically partitions the base into balanced, modular interlocking tiles.
3. **Fills the perimeter gaps**: Exterior tiles seamlessly integrate solid border spacers (or storage troughs) so the entire assembly locks securely inside your drawer without screws or glue.

---

## 🚀 Key Features

* **🖨️ Intelligent Multi-Bed / Printer Tiling**:
  * **Prusa CORE One / One+** ($250 \times 220\text{ mm}$): Max $5 \times 5$ cells per tile ($210 \times 210\text{ mm}$).
  * **Prusa MK4 / MK4S / MK3S+** ($250 \times 210\text{ mm}$): Balanced $5 \times 4$ cells per tile.
  * **Prusa XL** ($360 \times 360\text{ mm}$): High-capacity tiles up to $8 \times 8$ cells ($336 \times 336\text{ mm}$).
  * **Prusa MINI / MINI+** ($180 \times 180\text{ mm}$): Compact $4 \times 4$ tiles ($168 \times 168\text{ mm}$).
* **🧩 Modular Independent Objects**: Each tile is added as its own object in PrusaSlicer. Use PrusaSlicer's Auto-arrange (`A`) or assign tiles across multiple print beds.
* **🧲 Authentic Gridfinity Standard**: Standard 4.8 mm baseplate height with 3.4 mm divider walls, corner retention lugs, and $6.5\text{ mm}$ holes for $6\times 2\text{ mm}$ neodymium magnets spaced at 26 mm.
* **📦 Parametric Stackable Bins**: Generate matching Gridfinity bins ($1\times 1$, $1\times 2$, $2\times 2$, $3\times 3$, etc.) from 2U ($14\text{ mm}$) to 12U ($84\text{ mm}$) with sculpted feet and bottom magnet sockets resting flush on the print bed ($Z \ge 0$).
* **🛠️ Utility Gap Troughs**: Turn dead space at the back of the drawer into long horizontal trays for calipers, pens, rulers, or screwdrivers.
* **⚡ 100% Native In-Memory**: Instant zero-CAD generation directly onto the build plate without external dependencies.

---

## 🇪🇸 Descripción en Español

Plugin oficial para PrusaSlicer 3.0+ desarrollado por **3DEMS**. Diseña bases completas Gridfinity a la medida exacta de tu cajón:
* **Particionado automático por impresora**: Divide cajones grandes en baldosas equilibradas según la cama de tu **Core One**, **MK4**, **XL** o **MINI**.
* **Ajuste perimetral sin holguras (Gap Filler)**: Rellena los milímetros sobrantes para que la base quede fijada por presión en el cajón sin deslizarse ni necesitar adhesivos.
* **Cajas apilables compatibles**: Genera cajas modulares (1 a 4 celdas, 2U a 12U) con patas Gridfinity estándar y alojamientos para imanes de 6 mm.

---

## 📖 Quickstart / Cómo usarlo

1. Open PrusaSlicer and select the Plater view.
2. In the top menu, click **3DEMS** $\rightarrow$ **Gridfinity Drawer & Base**.
3. Enter your drawer's interior width and depth (e.g. `420` $\times$ `420` mm).
4. Choose your printer profile (or leave on **Auto-detect**).
5. Click **OK** $\rightarrow$ Tiles are placed on the plater ready to slice!

---

## Standard & Attribution
Based on the open-source **Gridfinity** modular storage specification created by **Zack Freedman (Voidstar Lab)** under the **MIT License**.

## Author & Marketplace
* **Author**: [3DEMS](https://github.com/3dems)
* **Author ID**: `9d2f6477-ddc2-4189-b873-d0026dd7a4ef`
* **Plugin ID**: `io.github.3dems.gridfinity-generator`
* **License**: AGPL-3.0-only
