import pandas as pd
print(pd.options.display.max_rows) 
pd.options.display.max_rows = 9999
print(pd.options.display.max_rows) 

dfJS = pd.read_csv('srcuniqjs.csv')
print('dfJS.info()')  
print(dfJS.info())  
print('end of dfJS.info')
dfJSD = pd.read_csv('srcuniqdepend.csv')
print('dfJSD.info()')  
print(dfJSD.info())  
print('end of dfJSD.info')

print ('dfJS.index=',dfJS.index)
print ('dfJSD.index=',dfJSD.index)

dfJS = dfJS.reset_index()  # make sure indexes pair with number of rows
if (len(dfJS)) == 0: 
	quit()
for jsindex in dfJS.index:
	thisjs=dfJS['JOBSTREAM'][jsindex]
	print("checking if this jobstream is on right=",thisjs)

	for jsdindex in dfJSD.index:
		print("comparing with",dfJSD['SUCCESSOR_JOBSTREAM'][jsdindex])
		if thisjs == dfJSD['SUCCESSOR_JOBSTREAM'][jsdindex]:
			print("found on the right")

print('Normal End')

