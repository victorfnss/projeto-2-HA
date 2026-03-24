resource "aws_key_pair" "minha_chave" {
  key_name   = "projeto-aws-key"
  public_key = file("~/.ssh/projeto-aws-key.pub")
}