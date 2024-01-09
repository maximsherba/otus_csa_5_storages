#VPC 
resource "aws_vpc" "storages_vpc" {
  tags = {
    Name = "storages_vpc"
  }
  cidr_block = "10.10.1.0/24"
}

#Subnets
resource "aws_subnet" "storages_subnet_a" {
  tags = {
    Name = "storages_subnet"
  }
  vpc_id     = aws_vpc.storages_vpc.id
  cidr_block = "10.10.1.0/26"
  availability_zone = "eu-west-3a"
}

resource "aws_subnet" "storages_subnet_b" {
  tags = {
    Name = "storages_subnet"
  }
  vpc_id     = aws_vpc.storages_vpc.id
  cidr_block = "10.10.1.64/26"
  availability_zone = "eu-west-3b"
}
 
#Volumes 
resource "aws_ebs_volume" "ebs_gp3" {
  availability_zone = "eu-west-3a"
  size              = 20
  type              = "gp3"
	
  tags = {
    Name = "MyEBS"
 }
} 

resource "aws_ebs_volume" "ebs_st1" {
  availability_zone = "eu-west-3a"
  size              = 125
  type              = "st1"
	
  tags = {
    Name = "MyEBS"
 }
} 

 
#Instances for testing
resource "aws_instance" "storage_test" {
  tags = {
    Name = "storage_test"
  }
  ami           = "ami-02ea01341a2884771"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.storages_subnet_a.id
#  security_groups = [aws_security_group.sg_WebA.id]
}

resource "aws_volume_attachment" "ebs_gp3_att" {
  device_name = "/dev/sdb"
  volume_id   = aws_ebs_volume.ebs_gp3.id
  instance_id = aws_instance.storage_test.id
}

resource "aws_volume_attachment" "ebs_st1_att" {
  device_name = "/dev/sdc"
  volume_id   = aws_ebs_volume.ebs_st1.id
  instance_id = aws_instance.storage_test.id
}

#Redis
resource "aws_elasticache_subnet_group" "ec_sg" {
  name       = "tf-test-cache-subnet"
  subnet_ids = [aws_subnet.storages_subnet_a.id, aws_subnet.storages_subnet_b.id]
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id        = "mycluster"
  engine            = "redis"
  node_type         = "cache.t3.micro"
  num_cache_nodes   = 1
  port              = 6379
  apply_immediately = true
  subnet_group_name    = aws_elasticache_subnet_group.ec_sg.name
}


