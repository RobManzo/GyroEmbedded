AE CONSTANT SLAVEADDR_W
1 SLAVEADDR_W + CONSTANT SLAVEADDR_R
0 CONSTANT INTSTATUS1


: READ ( data -- ) SLAVEADDR WRITEI2C ;


