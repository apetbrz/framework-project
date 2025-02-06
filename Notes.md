CRUD functionality

Database read/write

Three main endpoints: 
1) HTML homepage
2) Typical workload (password hashing? something else?)
   1) `/hash` POST endpoint:
       - takes in `{password: [SOME STRING]}`
       - generates a random UUID and stores in database table
       - returns `{password: [THAT STRING, HASHED], id: [THAT UUID]}`
3) Heavy workload (matrix multiplication? something heavy)