import pandas as pd

pd.options.display.max_rows = 9999      #output all rows in DF
#print(pd.options.display.max_rows) 

dfJS = pd.read_csv('uniqjs.csv')
#print(dfJS.info())  
dfJSD = pd.read_csv('jsdepend.csv')
#print(dfJSD.info())  

#print('starting position:')
#print (dfJS)
#print (dfJSD)
#print('deal with rows in jsd where left js is not in our master list')
for jsdindex,jsdrow in dfJSD.iterrows():
    thisjsd=jsdrow['JOBSTREAM']
    found=0
    for jsindex,jsrow in dfJS.iterrows():
        thisjs=jsrow['JOBSTREAM']
        if thisjs == thisjsd:
            found=1
    if (found == 0):          #not found in left so move right to the left
        rhjs=jsdrow['SUCCESSOR_JOBSTREAM']
        dfJSD.at[jsdindex,'JOBSTREAM']=rhjs
        dfJSD.at[jsdindex,'SUCCESSOR_JOBSTREAM']='xxx' #put non-existent js in right
#print('dealt with rows in jsd where js not in master list')
#print(dfJSD)
outputJSNum=1
print('ORDER,JOBSTREAM')
while True:
    #print ('numberToCheck=',len(dfJS))
    if (len(dfJS)) == 0: 
        quit()
    #print ('JS',dfJS)
    #print ('JSD',dfJSD)
    for jsindex, jsrow in dfJS.iterrows():              #for each entry in list1
        thisjs=jsrow['JOBSTREAM']
        #print("checking if this jobstream is on right=",thisjs)
        foundOnRight=0
        for jsdindex,jsdrow in dfJSD.iterrows():                  #check if the entry is on the right
            #print("comparing with",dfJSD['SUCCESSOR_JOBSTREAM'][jsdindex])
            if (thisjs == jsdrow['SUCCESSOR_JOBSTREAM']):
                foundOnRight=1
                #print (thisjs,'found on the right')
        if (foundOnRight==0):
            #print('outputing this js next due on left') #output it
            print("%d,%s" % (outputJSNum,thisjs))
            outputJSNum += 1
            for jsdindex,jsdrow in dfJSD.iterrows():    #we have to shift left all JS on the right
                if (thisjs==jsdrow['JOBSTREAM']):
                    rhjs=jsdrow['SUCCESSOR_JOBSTREAM']
                    if (rhjs != 'xxx'):
                        #print('shifting left',rhjs)
                        dfJSD.at[jsdindex,'JOBSTREAM']=rhjs
                        dfJSD.at[jsdindex,'SUCCESSOR_JOBSTREAM']='xxx'
                    else:
                        dfJSD.drop(jsdindex,inplace=True)
            dfJS.drop(jsindex, inplace=True) #wasnt found on the right and has been output, done with it

