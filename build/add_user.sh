#!/bin/bash
add_members() {
mongo --eval "rs.add(\"$SLAVE1:27017\")"
mongo --eval "rs.add(\"$SLAVE2:27017\")"
mongo --eval "t=rs.conf();t.members[0].priority=2;rs.reconfig(t);"
}
create_user() {
mongo  --eval "db.getSiblingDB(\"test\").createUser({user: \"test\",pwd: \"test\",roles:[{ role: \"readWrite\", db: \"test\" },{ role: \"read\", db: \"local\" },{ role: \"root\", db: \"admin\" },{ role: \"userAdminAnyDatabase\", db: \"admin\" },{ role: \"read\", db: \"admin\" }],writeConcern: { w: \"majority\" , wtimeout: 5000 }})"
mongo  --eval "db.getSiblingDB(\"activity\").createUser({user: \"test\",pwd: \"test\",roles:[{ role: \"readWrite\", db: \"activity\" },{ role: \"read\", db: \"activity\" },{ role: \"root\", db: \"admin\" },{ role: \"userAdminAnyDatabase\", db: \"admin\" },{ role: \"read\", db: \"admin\" }],writeConcern: { w: \"majority\" , wtimeout: 5000 }})"
mongo  --eval "db.getSiblingDB(\"fortest\").createUser({user: \"test\",pwd: \"test\",roles:[{ role: \"readWrite\", db: \"fortest\" },{ role: \"read\", db: \"local\" },{ role: \"root\", db: \"admin\" },{ role: \"userAdminAnyDatabase\", db: \"admin\" },{ role: \"read\", db: \"admin\" }],writeConcern: { w: \"majority\" , wtimeout: 5000 }})"
mongo  --eval "db.getSiblingDB(\"admin\").createUser({user: \"test\",pwd: \"test\",roles:[{ role: \"clusterAdmin\", db: \"admin\" },{ role: \"userAdminAnyDatabase\", db: \"admin\" },{ role: \"readWriteAnyDatabase\", db:\"admin\"},{ role: \"dbAdminAnyDatabase\", db:\"admin\"},{ role: \"root\", db: \"admin\" }],writeConcern: { w: \"majority\" , wtimeout: 5000 }})"
add_members
}
