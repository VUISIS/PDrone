module QGC = { QGC };
module Ardupilot = { Ardupilot };
module UART = { UART };
module UnstableUART = { UnstableUART };
module Network = { QGC, Ardupilot, UART };
module UnstableNetwork = { QGC, Ardupilot, UnstableUART };