import csv
import math
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
import numpy as np

N_vals, kernel_ms, e2e_ms, tp_compute, tp_system = [], [], [], [], []

with open("results.csv", encoding="utf-8-sig") as f:
    reader = csv.DictReader(f)
    reader.fieldnames = [name.strip() for name in reader.fieldnames if name]
    for row in reader:
        N_vals.append(int(row["N"]))
        kernel_ms.append(float(row["kernel_ms"]))
        e2e_ms.append(float(row["e2e_ms"]))
        tp_compute.append(float(row["throughput_compute_Mps"]))
        tp_system.append(float(row["throughput_system_Mps"]))

fpga_tp = [100.0] * len(N_vals)
fpga_lat_ms = [n / 1e8 * 1e3 for n in N_vals]

plt.style.use('dark_background')
plt.rcParams.update({
    "figure.facecolor": "#0d1117",
    "axes.facecolor": "#0d1117",
    "grid.color": "#21262d",
    "font.family": "monospace",
})

GPU_COMPUTE = "#58a6ff"
GPU_SYSTEM = "#3fb950"
FPGA_COLOR = "#f78166"

# 1. Throughput vs N
fig, ax = plt.subplots(figsize=(9, 5.5))
ax.plot(N_vals, tp_compute, "o-", color=GPU_COMPUTE, lw=2, label="GPU Compute", alpha=0.9)
ax.plot(N_vals, tp_system, "s-", color=GPU_SYSTEM, lw=2, label="GPU System", alpha=0.9)
ax.plot(N_vals, fpga_tp, "^-", color=FPGA_COLOR, lw=2, label="FPGA @ 100MHz", alpha=0.9)
ax.set_xscale("log")
ax.set_yscale("log")
ax.set_xlabel("N (angles)")
ax.set_ylabel("Throughput (M/s)")
ax.set_title("CORDIC Throughput: RTX 4060 vs Artix-7")
ax.legend(framealpha=0.2)
ax.grid(True, which="both")
ax.xaxis.set_major_formatter(ticker.FuncFormatter(lambda x, _: f"{int(x):,}"))
fig.tight_layout()
fig.savefig("throughput_vs_N.png", dpi=150, facecolor="#0d1117")
plt.close()

# 2. Latency vs N
fig, ax = plt.subplots(figsize=(9, 5.5))
ax.plot(N_vals, kernel_ms, "o-", color=GPU_COMPUTE, lw=2, label="GPU Kernel", alpha=0.9)
ax.plot(N_vals, e2e_ms, "s-", color=GPU_SYSTEM, lw=2, label="GPU E2E", alpha=0.9)
ax.plot(N_vals, fpga_lat_ms, "^-", color=FPGA_COLOR, lw=2, label="FPGA", alpha=0.9)
ax.set_xscale("log")
ax.set_yscale("log")
ax.set_xlabel("N (angles)")
ax.set_ylabel("Latency (ms)")
ax.set_title("CORDIC Latency: RTX 4060 vs Artix-7")
ax.legend(framealpha=0.2)
ax.grid(True, which="both")
ax.xaxis.set_major_formatter(ticker.FuncFormatter(lambda x, _: f"{int(x):,}"))
fig.tight_layout()
fig.savefig("latency_vs_N.png", dpi=150, facecolor="#0d1117")
plt.close()

# 3. Compute vs System
x = np.arange(len(N_vals))
width = 0.35
labels = [f"{n:,}" for n in N_vals]
fig, ax = plt.subplots(figsize=(9, 5.5))
ax.bar(x - width/2, tp_compute, width, label="Compute", color=GPU_COMPUTE, alpha=0.9)
ax.bar(x + width/2, tp_system, width, label="System", color=GPU_SYSTEM, alpha=0.9)
ax.set_xticks(x)
ax.set_xticklabels(labels)
ax.set_xlabel("N (angles)")
ax.set_ylabel("Throughput (M/s)")
ax.set_title("PCIe Overhead — RTX 4060")
ax.legend(framealpha=0.2)
ax.grid(True, axis="y")
fig.tight_layout()
fig.savefig("compute_vs_system.png", dpi=150, facecolor="#0d1117")
plt.close()

# 4. Error Distribution
angles, err_cos, err_sin = [], [], []
with open("verilog_errors.csv", "r") as f:
    next(f)
    for line in f:
        parts = line.strip().split(",")
        if len(parts) == 5:
            a = int(parts[0])
            exp_c, act_c = int(parts[1]), int(parts[2])
            exp_s, act_s = int(parts[3]), int(parts[4])
            angles.append(a / 16384.0)
            err_cos.append(act_c - exp_c)
            err_sin.append(act_s - exp_s)

fig, ax = plt.subplots(figsize=(9, 5.5))
ax.scatter(angles, err_cos, color=GPU_COMPUTE, s=8, label="Cosine Error", alpha=0.5, edgecolors='none')
ax.scatter(angles, err_sin, color=FPGA_COLOR, s=8, label="Sine Error", alpha=0.5, edgecolors='none')

if err_cos and err_sin:
    max_err = max(max(abs(e) for e in err_cos), max(abs(e) for e in err_sin))
    rmse = np.sqrt(np.mean(np.array(err_cos)**2 + np.array(err_sin)**2))
    stats_text = f"Q2.14 Arithmetic\nMax Error: ±{max_err} LSB\nRMSE: {rmse:.2f} LSB"
    props = dict(boxstyle='round', facecolor='#21262d', alpha=0.8, edgecolor='none')
    ax.text(0.95, 0.05, stats_text, transform=ax.transAxes, fontsize=10,
            verticalalignment='bottom', horizontalalignment='right', bbox=props, color='white')

ax.set_xlabel("Input Angle (radians)")
ax.set_ylabel("Quantization Error (LSB)")
ax.set_title("CORDIC Hardware Error Distribution vs FP32 Reference")
ax.legend(framealpha=0.2, markerscale=2, loc="upper left")
ax.grid(True, linestyle="--", alpha=0.3)
ax.axhline(0, color='white', linewidth=0.8, alpha=0.5)

ax.xaxis.set_major_locator(ticker.MultipleLocator(base=math.pi/4))
ax.xaxis.set_major_formatter(ticker.FuncFormatter(lambda val, pos: f"{val/math.pi:.2g}π" if val != 0 else "0"))

fig.tight_layout()
fig.savefig("error_distribution.png", dpi=150, facecolor="#0d1117")
plt.close()
