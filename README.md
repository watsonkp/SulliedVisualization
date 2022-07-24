# SulliedVisualization

A Swift package intended for use by iOS applications to visualize data in a variety of ways. It currently includes plots of data over time and positional data, as well as a calendar marking occurrences. Plots can be dynamic, allowing a user to pan and zoom into the plotted data. Gridlines and coloured regions can be overlayed on plots. Axis markings are generated dynamically and attempt to use values that are easily readable by a human while fitting the data closely.

This project is a work in progress. The immediate future involves adding more functionality to the calendar view, more thorough support for [measurements](https://developer.apple.com/documentation/foundation/measurement), and making the gestures supported by the dynamic plots smoother by fixing a few bugs.

At WWDC 2022 Apple announced [Swift Charts](https://developer.apple.com/videos/play/wwdc2022/10136/), so this library may become much less useful. I haven't tested the library yet, but I'm sure I will still be able to think of visualizations that Apple hasn't implemented once it's released.
