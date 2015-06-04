
customerAuditUtils ={}

local audit   = require "dauditParser"
local tim     = require "tim" 
local utils   = require "utils"
local fo = require "fo"

table_count={} -- Count no. of records for each table
audit_table = {}
function cb(op,table,x)
	if type(table_count[table]) == 'nil' then
		table_count[table]=1
		audit_table[table]={}
	else 
		table_count[table] = table_count[table] + 1
	end
--	print("table :",table)
	--print("x :",utils.prettystr(x))
	local index = table_count[table]
	local array={index,x}
	insert(audit_table[table],array)
end	

function insert(tempTable,input)
	table.insert(tempTable,input)
end

function customerAuditUtils.query()
	audit.query{
		onUpdate = cb,
		onError  = function( x ) print( x ) end,
		from     = tim.Date"26.05.2015",
		to       = tim.Date"26.05.2015",
		tables   = {'clients','deposits','lim_ordvol'},
		mandators= {},
	}
  customerAuditUtils.audit_table = audit_table
end


function customerAuditUtils.getTable(audit_table,table_name)
	local objects = {}
	local result = {}
	if type(audit_table[table_name]) ~= 'table' then
		return result 
	end
	
	objects = audit_table[table_name]
	for _,object in pairs(objects) do
		table.insert(result,object[2])
	end
	return result
end

function customerAuditUtils.getClientDb(clients)
	local clientList = {}
	for _,client in pairs(clients) do
		local	clientItem = {}
		local client_id = client['clientnummer']
		--local client_obj = fo.Client("4460")
		--print ("Client obj : ",utils.prettystr(client_obj))
		table.insert(clientItem,{'client_number',client_id})
			
		for field,data in pairs(client) do
			if type(data) == 'table' then
				local field_old = field..'_old'
				local field_new = field..'_new'
				table.insert(clientItem,{field_old,data[1]})
				table.insert(clientItem,{field_new,data[2]})
				--print("v : ",utils.prettystr(v))
			end
		end
		table.insert(clientList,clientItem)
	end
	return clientList	
end

function customerAuditUtils.getDepositDb(clients)
	local clientList = {}
	for _,client in pairs(clients) do
		local	clientItem = {}
		local depot_nummer= client['depotnummer']
		local portfolio_nr = client['portfolionr']	
		table.insert(clientItem,{'depot_number',depot_nummer})
		table.insert(clientItem,{'portfolio_nr',portfolio_nr})
		
		for field,data in pairs(client) do
			if type(data) == 'table' then
				local field_old = field..'_old'
				local field_new = field..'_new'
				table.insert(clientItem,{field_old,data[1]})
				table.insert(clientItem,{field_new,data[2]})
			end
		end
		table.insert(clientList,clientItem)
	end
	return clientList	
end

--customerAuditUtils.query()
--print("clients : ",utils.prettystr(clients))
--local deposits = getTable(audit_table,'deposits')
--print("deposits: ",utils.prettystr(deposits))
--local lim_ordvol = getTable(audit_table,'lim_ordvol')
--print("lim_ordvol : ",utils.prettystr(lim_ordvol))
--local clientList = getClientDb(clients)
--local depositList = getDepositDb(deposits)

return customerAuditUtils
--local ordvolList = getClientDb(lim_ordvol)
--print("clientList",utils.prettystr(clientList))
--print("depositList",utils.prettystr(depositList))
--print("ordvolList",utils.prettystr(ordvolList))
