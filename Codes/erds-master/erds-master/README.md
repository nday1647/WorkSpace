![Python 2.7](https://img.shields.io/badge/python-2.7-green.svg)
![Python 3.6](https://img.shields.io/badge/python-3.6-green.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)

ERDS
====
This package calculates and displays ERDS maps of event-related EEG/MEG data. ERDS is short for event-related desynchronization (ERD) and event-related synchronization (ERS). Conceptually, ERD corresponds to a decrease in power in a specific frequency band relative to a baseline. Similarly, ERS corresponds to an increase in power.

Usage
-----
The `erds` package uses an API similar to the one used in `scikit-learn`. Here is a simple example demonstrating the basic usage (note that the actual code for loading the data is missing):

```python
from erds import Erds

maps = Erds()
maps.fit(data)  # data must be available in appropriate format
maps.plot()
```

Data format
-----------
The input data must be organized in a three-dimensional NumPy array with a shape of `(n_epochs, n_channels, n_samples)`. This means that the continuous raw EEG data must be epoched prior to ERDS map calculation. The function `utils.make_epochs` can be used for this purpose.

Output
------
After computing ERDS maps using the `fit` method, the following values are available within an `Erds` object (note that all computed values have names ending with `_`):

`erds_`: The actual ERDS maps with shape `n_freqs, n_channels, n_times`

`cl_`, `cu_`: Lower and upper confidence intervals of ERDS maps (if computed)

`freqs_`: Frequency bins of ERDS maps (visualized on the y-axis)

`times_`: Time points of ERDS maps (visualized on the x-axis)

`n_channels_`, `n_epochs_`, `n_samples_`: Number of channels, epochs, and samples per epoch of the input data

Examples
--------
Example scripts demonstrating some features of the package can be found in the `examples` folder.

Dependencies
------------
The package requires [NumPy](http://www.numpy.org/). Optionally, [matplotlib](http://matplotlib.org/) is used to plot ERDS maps.

References
----------
[G. Pfurtscheller, F. H. Lopes da Silva. Event-related EEG/MEG synchronization and desynchronization: basic principles. Clinical Neurophysiology 110(11), 1842-1857, 1999.][1]

[B. Graimann, J. E. Huggins, S. P. Levine, G. Pfurtscheller. Visualization of significant ERD/ERS patterns in multichannel EEG and ECoG data. Clinical  Neurophysiology 113(1), 43-47, 2002.][2]

[1]: http://dx.doi.org/10.1016/S1388-2457(99)00141-8
[2]: http://dx.doi.org/10.1016/S1388-2457(01)00697-6
