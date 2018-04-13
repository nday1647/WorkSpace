import numpy as np


def make_epochs(x, cues, start, stop):
    """Create epochs from continuous input signal.

    Parameters
    ----------
    x : ndarray, shape (m, n)
        Input data with m signals and n samples.
    cues : list of int
        Positions (indices) of cues within data.
    start : int
        Window start (offset relative to cue in samples).
    stop : int
        Window end (offset relative to cue in samples).

    Returns
    -------
    epochs : array, shape (len(cues), m, stop-start)
        Resulting epochs stacked along the first axis.
    """
    if start != int(start):
        raise ValueError("start index must be an integer")
    if stop != int(stop):
        raise ValueError("stop index must be an integer")

    x = np.atleast_2d(x)
    cues = np.asarray(cues, dtype=int).ravel()
    win = np.arange(start, stop, dtype=int)
    return np.concatenate([x[np.newaxis, :, cue + win] for cue in cues])
