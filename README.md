# Terraform-code-VPC-
This is a terraform code that create a vpc using the modular approach that satify the following conditions:

1. when user give a public subnet CIDR the public subnet is created according to the number of user given CIDR block number it menas when user give 1 number of public subnet CIDR  the 1 public subnet is created and when user give us 2 subnet CIDRs block the 2 public subnet is created.
   it menas the number of public subnet is equal to the given number numbers of public subnet CIDRs.
2. when the user give us 0 number of private subnet CIDR the private subnet is not created and other component  related to the private subnet such as private route table , nat gateway ,elastic ip etc not created .
   and when the user give us 1 number of private subnet CIDR the private subnet 1 created and other component  related to the private subnet such as 1private route table , 1nat gateway ,1elastic ip etc  created .
    And when the user give us 2 number of private subnet CIDR the private subnet 2 created and other component  related to the private subnet such as 2private route table , 2nat gateway ,2elastic ip etc  created . 
