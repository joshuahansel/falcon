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

data = readMOOSEXML('wells.xml')
final_index = len(data) - 1

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
  return data[vpp]['x'][final_index]

def getVarValues(data, vpp, var):
  # y_heated_pipe = data['heated_pipe_vpp'][var][0]
  # y_top_pipe = data['top_pipe_vpp'][var][0]
  # y_cooled_pipe = data['cooled_pipe_vpp'][var][0]
  # y_bottom_pipe = data['bottom_pipe_vpp'][var][0]

  # y_cooled_pipe.reverse()
  # y_bottom_pipe.reverse()

  # return y_heated_pipe + y_top_pipe + y_cooled_pipe + y_bottom_pipe
  return data[vpp][var][final_index]

def plotSet(data, vpp, var, color, linestyle, label):
  x = getXValues(data, vpp)
  var_values = getVarValues(data, vpp, var)
  plt.plot(x, var_values, linestyle=linestyle, color=color, marker='.', label=label)

def makePlot(var, y_label):
  plt.figure(figsize=(8, 6))
  plt.rc('text', usetex=True)
  plt.rc('font', family='sans-serif')
  ax = plt.subplot(1, 1, 1)
  ax.get_yaxis().get_major_formatter().set_useOffset(False)
  plt.xlabel("x Position [m]")
  plt.ylabel(y_label)
  plotSet(data, var + '_inj',  var, 'lightgreen', '-', "Injection well")
  plotSet(data, var + '_frac', var, 'black', '-', "Fracture channel")
  plotSet(data, var + '_ext',  var, 'indianred', '-', "Extraction well")
  ax.legend()
  plt.tight_layout()
  plt.savefig('final_' + var + '.png', dpi=300)

# def makeElevationPlot(var, y_label):
#   makePlot()

# makePlot('rho', 'Density [kg/m$^3$]')
# makePlot('T', 'Temperature [K]')
makePlot('p', 'Pressure [Pa]')
makePlot('rhouA', 'Mass Flow Rate [kg/s]')
