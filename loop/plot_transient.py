import sys
import os
import matplotlib.pyplot as plt

app_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
app_python_dir = os.path.join(app_dir, 'python')
if app_python_dir not in sys.path:
  sys.path.append(app_python_dir)

from falcon_utilities import addTHMPythonPath
addTHMPythonPath(app_dir)
from thm_utilities import readCSVFile

wells_data = readCSVFile('wells.csv')
fracs_data = readCSVFile('fracs.csv')

def makePlot(var, y_label):
  plt.figure(figsize=(8, 6))
  plt.rc('text', usetex=True)
  plt.rc('font', family='sans-serif')
  ax = plt.subplot(1, 1, 1)
  ax.get_yaxis().get_major_formatter().set_useOffset(False)
  plt.xlabel("Time [s]")
  plt.ylabel(y_label)
  plt.plot(wells_data['time'], wells_data[var + '_inlet'],  linestyle='-', marker='', color='limegreen', label="Inlet")
  plt.plot(fracs_data['time'], fracs_data[var + '_frac1'],  linestyle='-', marker='', color='orange', label="Fracture 1")
  plt.plot(fracs_data['time'], fracs_data[var + '_frac2'],  linestyle='-', marker='', color='cornflowerblue', label="Fracture 2")
  plt.plot(wells_data['time'], wells_data[var + '_outlet'], linestyle='-', marker='', color='indianred', label="Outlet")
  ax.legend()
  plt.tight_layout()
  plt.savefig(var + '_transient.png', dpi=300)

makePlot('p', 'Pressure [Pa]')
makePlot('mass_rate', 'Mass Flow Rate [kg/s]')
