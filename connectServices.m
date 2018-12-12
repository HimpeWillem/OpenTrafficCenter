function connectServices(type)

global conn_KUL;
global conn_type;

conn_type = type;
switch type
    case 'odbc'
        conn_KUL = database('kul_db', 'student1','student1');

    case 'jdbc'
        conn_KUL = database('postgres', 'student1','student1', 'Vendor', 'POSTGRESQL', 'Server', 'db.itscrealab.be', 'PortNumber', 5432);
end
        
if isempty(conn_KUL.Message)
    display('Connection to KUL service succeeded');
else
    display('Connection to KUL service failed');
end

end