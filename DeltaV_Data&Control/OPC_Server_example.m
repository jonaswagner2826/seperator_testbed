% Locating an OPC Server
hostInfo = opcserverinfo('localhost')
hostInfo.ServerDescription'
allID = hostInfo.ServerID'

% Construct Client
da = opcda('localhost','Matrikon.OPC.Simulation.1')
connect(da)

% Get Server Namespace
ns = getnamespace(da)
ns(1)

% Find Items in Namespace
realItems = serveritems(ns,'*Real*')

% Query Server Item Properties
canDT = serveritemprops(da,realItems{2},1)
accessRights = serveritemprops(da,realItems{2},5)

% Close everything up
disconnect(da)
delete(da)