"""
=============================================================
 FSM Digital Signal Generator — Waveform Visualizer
 Reads simulation output files and plots all 4 waveforms
=============================================================
 Usage:
   python plot_waveforms.py
 
 Make sure these files are in the same directory:
   square_out.txt, sawtooth_out.txt,
   triangle_out.txt, sine_out.txt
=============================================================
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
import os, sys

# ── Config ─────────────────────────────────────────────────
FILES = {
    "Square":   "square_out.txt",
    "Sawtooth": "sawtooth_out.txt",
    "Triangle": "triangle_out.txt",
    "Sine":     "sine_out.txt",
}

COLORS = {
    "Square":   "#00C8FF",   # cyan
    "Sawtooth": "#FF6B35",   # orange
    "Triangle": "#A8FF3E",   # lime
    "Sine":     "#FF3CAC",   # magenta
}

BG_DARK  = "#0D1117"
BG_PANEL = "#161B22"
GRID_CLR = "#30363D"
TEXT_CLR = "#E6EDF3"

# ── Load data ───────────────────────────────────────────────
def load(path):
    if not os.path.exists(path):
        print(f"[ERROR] File not found: {path}")
        print("        Run the Verilog simulation first to generate .txt files.")
        sys.exit(1)
    data = []
    with open(path) as f:
        for line in f:
            line = line.strip()
            if line:
                try:
                    data.append(int(line))
                except ValueError:
                    pass  # skip non-numeric lines
    return np.array(data, dtype=np.float32)

samples = {name: load(path) for name, path in FILES.items()}

# ── Figure layout ────────────────────────────────────────────
fig = plt.figure(figsize=(16, 10), facecolor=BG_DARK)
fig.suptitle(
    "FSM-Based Digital Signal Generator  ·  Simulation Output",
    fontsize=17, fontweight="bold", color=TEXT_CLR,
    y=0.97, fontfamily="monospace"
)

gs = gridspec.GridSpec(
    2, 2,
    figure=fig,
    hspace=0.52, wspace=0.35,
    left=0.07, right=0.97,
    top=0.90, bottom=0.07
)

axes = [
    fig.add_subplot(gs[0, 0]),
    fig.add_subplot(gs[0, 1]),
    fig.add_subplot(gs[1, 0]),
    fig.add_subplot(gs[1, 1]),
]

# ── Plot each waveform ───────────────────────────────────────
for ax, (name, color) in zip(axes, COLORS.items()):
    y = samples[name]
    x = np.arange(len(y))

    # Panel background
    ax.set_facecolor(BG_PANEL)
    for spine in ax.spines.values():
        spine.set_edgecolor(GRID_CLR)

    # Grid
    ax.grid(True, color=GRID_CLR, linewidth=0.6, linestyle="--", alpha=0.8)
    ax.set_axisbelow(True)

    # Waveform — use step plot for square/sawtooth, line for others
    if name in ("Square", "Sawtooth"):
        ax.step(x, y, where="post", color=color, linewidth=1.8, alpha=0.95)
    else:
        ax.plot(x, y, color=color, linewidth=1.8, alpha=0.95)

    # Filled area under curve
    ax.fill_between(x, y, alpha=0.12, color=color,
                    step="post" if name in ("Square","Sawtooth") else None)

    # Axis labels & ticks
    ax.set_xlim(0, len(y) - 1)
    ax.set_ylim(-10, 270)
    ax.set_yticks([0, 64, 128, 192, 255])
    ax.set_yticklabels(["0", "64", "128", "192", "255"],
                       color=TEXT_CLR, fontsize=9)
    ax.set_xlabel("Sample Index", color=TEXT_CLR, fontsize=10)
    ax.set_ylabel("Amplitude (8-bit)", color=TEXT_CLR, fontsize=10)
    ax.tick_params(colors=TEXT_CLR, which="both")

    # Title with waveform symbol
    symbols = {"Square": "⊓", "Sawtooth": "⟋", "Triangle": "∧", "Sine": "∿"}
    ax.set_title(
        f"{symbols[name]}  {name} Wave",
        color=color, fontsize=13, fontweight="bold",
        fontfamily="monospace", pad=8
    )

    # Stats annotation
    stats = (f"min={int(y.min())}  max={int(y.max())}  "
             f"mean={y.mean():.1f}  samples={len(y)}")
    ax.annotate(
        stats, xy=(0.5, -0.22), xycoords="axes fraction",
        ha="center", color="#8B949E", fontsize=8.5, fontfamily="monospace"
    )

# ── Footer ───────────────────────────────────────────────────
fig.text(
    0.5, 0.01,
    "Verilog HDL Simulation  |  8-bit unsigned samples  |  wave_sel[1:0]: 00=Square  01=Sawtooth  10=Triangle  11=Sine",
    ha="center", color="#8B949E", fontsize=8.5, fontfamily="monospace"
)

plt.savefig("waveforms.png", dpi=180, bbox_inches="tight",
            facecolor=BG_DARK)
print("[✓] Saved → waveforms.png")
plt.show()
