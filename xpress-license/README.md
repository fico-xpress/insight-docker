# Using Xpress Solver License

You can add a solver license to your worker by following these steps:
1. Place there an `xpauth.xpr` license file to `xpress-license` folder
2. In `/worker-config/override.properties` add the new line:
```
insight.worker.execution.environment.XPAUTH_PATH=/xpress-license/xpauth.xpr
```