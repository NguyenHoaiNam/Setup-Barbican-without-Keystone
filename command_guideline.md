#### As we are running Barbican without Keystone, so there will be some options added when running the commands

##### Method 1

###### List secret

```
barbican --no-auth --endpoint http://localhost:9311 --os-project-id barbican  secret list
```

###### Store secret

```
barbican --no-auth --endpoint http://localhost:9311 --os-project-id barbican  secret store -p "nguyen hoai nam"
```

##### Method 2:

###### Add alias
```
echo "alias barbican='barbican --no-auth --endpoint http://localhost:9311 --os-project-id barbican'" >> ~/.bashrc
```
After that, we can use the commands in Barbican as normally.

