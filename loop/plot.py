import sys
import os
import matplotlib.pyplot as plt

app_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
app_python_dir = os.path.join(app_dir, 'python')
if app_python_dir not in sys.path:
  sys.path.append(app_python_dir)

from falcon_utilities import addTHMPythonPath
addTHMPythonPath(app_dir)
from thm_utilities import readMOOSEXML

wells_data = readMOOSEXML('wells.xml')
fracs_data = readMOOSEXML('fracs.xml')

def getXValues(data, vpp):
  # z_heated_pipe = data['heated_pipe_vpp']['z'][0]
  # x_top_pipe = data['top_pipe_vpp']['x'][0]
  # z_cooled_pipe = data['cooled_pipe_vpp']['z'][0]
  # x_bottom_pipe = data['bottom_pipe_vpp']['x'][0]
  # x_all = z_heated_pipe \
  #   + [1.0 + i for i in x_top_pipe] \
  #   + [2.0 + (1.0 - i) for i in reversed(z_cooled_pipe)] \
  #   + [3.0 + (1.0 - i) for i in reversed(x_bottom_pipe)]
  # return x_all
  return data[vpp]['x'][-1]

def getVarValues(data, vpp, var):
  # y_heated_pipe = data['heated_pipe_vpp'][var][0]
  # y_top_pipe = data['top_pipe_vpp'][var][0]
  # y_cooled_pipe = data['cooled_pipe_vpp'][var][0]
  # y_bottom_pipe = data['bottom_pipe_vpp'][var][0]

  # y_cooled_pipe.reverse()
  # y_bottom_pipe.reverse()

  # return y_heated_pipe + y_top_pipe + y_cooled_pipe + y_bottom_pipe
  return data[vpp][var][-1]

def plotSet(data, vpp, var, color, linestyle, label):
  x = getXValues(data, vpp)
  var_values = getVarValues(data, vpp, var)
  plt.plot(x, var_values, linestyle=linestyle, color=color, marker='.', label=label)

def makePlot(var, vpp_suffix, y_label):
  plt.figure(figsize=(8, 6))
  plt.rc('text', usetex=True)
  plt.rc('font', family='sans-serif')
  ax = plt.subplot(1, 1, 1)
  ax.get_yaxis().get_major_formatter().set_useOffset(False)
  plt.xlabel("x Position [m]")
  plt.ylabel(y_label)
  plotSet(wells_data, 'inj1:' + vpp_suffix,  var, 'lightgreen', '-', "Injection 1")
  plotSet(wells_data, 'inj2:' + vpp_suffix,  var, 'limegreen', '-', "Injection 2")
  plotSet(wells_data, 'inj3:' + vpp_suffix,  var, 'forestgreen', '-', "Injection 3")
  plotSet(fracs_data, 'frac1:' + vpp_suffix, var, 'orange', '-', "Fracture 1")
  plotSet(fracs_data, 'frac2:' + vpp_suffix, var, 'cornflowerblue', '-', "Fracture 2")
  plotSet(wells_data, 'pro1:' + vpp_suffix,  var, 'lightcoral', '-', "Extraction 1")
  plotSet(wells_data, 'pro2:' + vpp_suffix,  var, 'tomato', '-', "Extraction 2")
  plotSet(wells_data, 'pro3:' + vpp_suffix,  var, 'firebrick', '-', "Extraction 3")
  # plotSet(data, vpp_base + '_ext',  var, 'indianred', '-', "Extraction well")
  ax.legend()
  plt.tight_layout()
  plt.savefig('final_' + var + '.png', dpi=300)

# def makeElevationPlot(var, y_label):
#   makePlot()

# makePlot('rho', 'Density [kg/m$^3$]')
# makePlot('T', 'Temperature [K]')
makePlot('p', 'vars_vpp', 'Pressure [Pa]')
# makePlot('rhouA', 'rhouA', 'Mass Flow Rate [kg/s]')
makePlot('mass_flux', 'flux_vpp', 'Mass Flow Rate [kg/s]')
