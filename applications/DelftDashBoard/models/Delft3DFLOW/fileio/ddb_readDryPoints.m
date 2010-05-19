function [m1,n1,m2,n2]=ddb_readDryPoints(fname);

m1=[];
m2=[];
n1=[];
n2=[];

dat=load(fname);
m1=dat(:,1);
n1=dat(:,2);
m2=dat(:,3);
n2=dat(:,4);

