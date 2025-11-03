output "ami_id" {
  value = tolist(tolist(aws_imagebuilder_image.this.output_resources)[0].amis)[0].image
}