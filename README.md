# Terraform AWS Static Site

## Results

This will result in a CICD set up automatically deploying your static website that lives in a github repo. It will have HTTPS and will automatically deploy on pushing to the branch you configure. Note, that in your website repo you will need a `buildspec.yml` configuring the specifics of how to compile and your entry point to your website. 

## Prequesites

1. Website Code Hosted on Github and an account OAUTH Token
2. A root domain name / hosted zone created in Route 53
3. A SSL cert provisioned in AWS Certificate Manager

## How to Execute

In your terraform files, import the module by github URL and include the required variables: 

```
module "website" {
    source = "git::git@github.com:schoenfelde/terraform-static-site-with-cicd.git//main"
    website_name = "site.domain" //Your Desired URL
    environment = "dev"
    acm_arn = "arn::...."
    r53_zone_id = "XXXX"
    github_oauth_token = "XXXX"
    github_repo_name = "repoName"
    github_branch_name = "branchName"
    github_owner_name = "branchName"
}
```


