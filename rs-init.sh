#replica set initial
mongo << 'EOF'
rsconf = {
           _id: "RS1",
           members: [
                      {
                       _id: 0,
                       host: "mongo1:27017"
                      }
                    ]
         };
rs.initiate(rsconf);
EOF

####create user & login as admin to do following

$ mongo -u admin -p xxxxxxx admin
RS1:PRIMARY> rs.add("mongo2:27017")
RS1:PRIMARY> rs.add("mongo3:27017")


#rs.addArb("id-perf-mongo3.dev.usw1.cs-htc.co:27017")