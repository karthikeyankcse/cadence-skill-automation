# Cadence Allegro SKILL Automation

A collection of **21 production-ready automation programs** built using Cadence SKILL for Allegro PCB Editor. These tools eliminate repetitive manual tasks in PCB design workflows — developed over 6+ years of hands-on EDA engineering.

---

## 📦 Programs

| Program | Description |
|---|---|
| **Add Net To Bus** | Automatically assigns nets to bus structures in the PCB layout |
| **Add Tri Shape Power** | Adds triangular copper shapes to power nets for thermal/current handling |
| **Airgap Between Outline and Shape** | Validates and enforces minimum airgap between board outline and copper shapes |
| **Assembly & Silk Subdrawing** | Automates generation of assembly and silkscreen subdrawings |
| **Auto Wiggle Create** | Serpentine/meander trace generator with ARC, 45-DEG, and U-SHAPE modes using binary search geometry math |
| **Back Drill** | Automates back-drilling definitions for controlled depth via processing |
| **Cad File** | CAD file processing and format conversion utilities |
| **Change Width** | Batch trace width modification across nets or layers |
| **Checking** | Design rule and layout validation checks |
| **Coupon Board Checks** | Suite of 7 coupon board validators — BGA via patterns, boundary airgap, cutout symbol verification, dummy copper, GND near-via, trace routing |
| **Decaps** | Automated decoupling capacitor placement optimization near ICs |
| **Depad** | Automated pad removal and cleanup utility |
| **Differential Pair** | Differential pair routing validation and length matching |
| **Group Create** | Automated component group creation for placement management |
| **Impedance Table** | Dynamic impedance table generator on PCB canvas from OHM constraint sets with grid column math and layer naming |
| **NetName Silk Create** | Auto-generates silkscreen net name labels on PCB canvas |
| **Reduce Board Extend** | Board outline reduction and extension automation |
| **SwapList** | Component swap list generation and validation |
| **Telesis** | Telesis format data processing and output |
| **Template Compare** | Compares component placement (XY, rotation, mirror) between Work and Template BRD files with field-level mismatch logging |
| **Via Replace or Delete** | Batch via replacement or deletion across the design |
| **X Section** | Cross-section data extraction and reporting |

---

## 🚀 Highlights

- **Auto Wiggle Create** — Generates serpentine traces mathematically. ARC mode uses binary search (80 iterations) to solve for theta; 45-DEG mode uses closed-form geometry. Supports length-matched routing for high-speed designs.
- **Template Compare** — Compares full placement data between two BRD files and outputs `PlacementErrors.log` (field-level mismatches) and `MissingInTemplate.log`. Filters KELVIN-named symbols automatically.
- **Coupon Board Checks** — 7-in-1 validation suite for coupon board manufacturing requirements.
- **Impedance Table** — Reads OHM constraint sets and auto-generates formatted impedance tables directly on the PCB canvas.

---

## 🛠️ Requirements

- Cadence Allegro PCB Editor (SPB 17.2 or higher)
- SKILL scripting enabled in Allegro environment

---

## 📂 Usage

1. Open Cadence Allegro PCB Editor
2. Go to **File → Script** or open the **SKILL REPL**
3. Load the `.il` file: `load("path/to/script.il")`
4. Run the program function as documented in each script's header comments

---

## 👤 Author

**Karthikeyan K** — EDA Automation Engineer  
[github.com/karthikeyankcse](https://github.com/karthikeyankcse)
