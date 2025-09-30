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

data_standalone = readCSVFile('outputs/fracs_standalone.csv')
data_coupled = readCSVFile('outputs/fracs.csv')


# def makePlot(var, pp_name, y_label, scale):
def makePlot(var, y_label, scale):
  plt.figure(figsize=(8, 6))
  plt.rc('text', usetex=True)
  plt.rc('font', family='sans-serif')
  ax = plt.subplot(1, 1, 1)
  ax.get_yaxis().get_major_formatter().set_useOffset(False)
  plt.xlabel("Time [s]")
  plt.ylabel(y_label)
  # plt.plot(data['time'], data['p_inj1'] / scale,  linestyle='-', marker='', color='mediumpurple', label="Injection 1")
  # plt.plot(data['time'], data['p_inj2'] / scale,  linestyle='-', marker='', color='cornflowerblue', label="Injection 2")
  # plt.plot(data['time'], data['p_inj3'] / scale,  linestyle='-', marker='', color='limegreen', label="Injection 3")
  # plt.plot(data['time'], data['p_pro1'] / scale,  linestyle='--', marker='', color='mediumpurple', label="Production 1")
  # plt.plot(data['time'], data['p_pro2'] / scale,  linestyle='--', marker='', color='cornflowerblue', label="Production 2")
  # plt.plot(data['time'], data['p_pro3'] / scale,  linestyle='--', marker='', color='limegreen', label="Production 3")
  plt.plot(data_standalone['time'], data_standalone['injection_rate_kg_s'],  linestyle='--', marker='', color='cornflowerblue', label="Total Injection, Standalone")
  plt.plot(data_standalone['time'], data_standalone['fluid_report'],  linestyle='--', marker='', color='indianred', label="Total Production, Standalone")
  inj1 = data_coupled['mass_rate_inj1']
  inj2 = data_coupled['mass_rate_inj2']
  inj3 = data_coupled['mass_rate_inj3']
  total_inj = inj1 + inj2 + inj3
  pro1 = data_coupled['mass_rate_pro1']
  pro2 = data_coupled['mass_rate_pro2']
  pro3 = data_coupled['mass_rate_pro3']
  total_pro = pro1 + pro2 + pro3
  plt.plot(data_coupled['time'], total_inj,  linestyle='-', marker='', color='cornflowerblue', label="Total Injection, Coupled")
  plt.plot(data_coupled['time'], total_pro,  linestyle='-', marker='', color='indianred', label="Total Production, Coupled")
  ax.set_xlim([min(data_coupled['time']), max(data_coupled['time'])])
  ax.legend()
  plt.tight_layout()
  plt.savefig('outputs/' + var + '_transient.png', dpi=300)



# makePlot('p', 'Pressure [MPa]', 1e6)
makePlot('mass_rate', 'Mass Flow Rate [kg/s]', 1)
