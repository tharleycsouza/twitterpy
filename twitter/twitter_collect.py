from twitter import *

t_auth= Twitter(
    auth=OAuth("230442545-TtS8wzuibMicXciouwuyjyAr8tjerIwetAreq3neS", 
               "APsSKDePkpajjyMwefjzhEhEhfUKhffXdHLOgfg4p1dda8Fdmqda0p", 
               "Ps7fw71NyQ9FTy8rk44xCvf9f8", 
               "pQde37Opff20hmj3pyDPfLfDsfmnYzu7ASTsUEd5qfWyfe1f0afuD1FPJ"))

list_tags = ["#cloud", "#container", "#devops", "#aws", "#microservices",
              "#docker", "#openstack", "#automation", "#gcp", "#azure", "#istio", "#sre"]
 

t_auth.search.tweets(q="#cloud")
