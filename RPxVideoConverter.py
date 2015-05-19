#!/usr/bin/env python

import time
import os
import glob
import sys
import shutil

def RPxLog(severity, message):
	print time.time(), severity, message

def RPxErrLog(message):
	RPxLog("E", message)

def RPxInfoLog(message):
	RPxLog("I", message)

def RPxDevLog(message):
	RPxLog("D", message)

scriptDir = os.path.abspath(os.path.dirname(__file__))

folderWithVideos = sys.argv[1] if (len(sys.argv) > 1) else scriptDir

someErrors = False
filesInOriginalFormat = glob.glob(folderWithVideos + "/*.h264")
if len(filesInOriginalFormat) == 0:
	RPxInfoLog("Noting to convert, no h264 RAW files")
	sys.exit(0)


RPxInfoLog("Start Converting")
for fileToConvert in filesInOriginalFormat:
	destinationFilePath = fileToConvert + ".mp4"
	RPxDevLog("Converting " + fileToConvert)
	result = os.system("avconv -i \"" + fileToConvert + "\" -c:v copy \"" + destinationFilePath + "\"");
	if result != 0:
		RPxErrLog("Failed to convert file: " + fileToConvert)
		someErrors = True
	else:
		shutil.copystat(fileToConvert, destinationFilePath)
		RPxDevLog("Converting Complete. New file: " + destinationFilePath)
		os.remove(fileToConvert);

if someErrors:
	RPxInfoLog("Done all, WITH ERRORS")
else:
	RPxInfoLog("Done all, no errors")
