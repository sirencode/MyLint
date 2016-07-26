##AndroidLint
Android Lint是一个静态代码分析工具，它能够对你的Android项目中潜在的bug、可优化的代码、安全性、性能、可用性、可访问性、国际化等进行检查。

Android Lint内置了很多lint规则，到现在为止是220项检查，总共可以分为以下几类：

* Correctness 正确性
* Security 安全性
* Performance 性能
* Usability 可用性
* Accessibility 可访问性
* Internationalization 国际化

你可以为lint检查配置不同的level：

* 全局（对整个project）
* 每个project module
* 每个production module
* 每个test module
* 每个open files
* 每个class hierarchy
* 每个Version Control System (VCS) scopes

##自定义Lint实现
自定义lint是一个纯java项目，以jar的形式输出。有了包含lint规则的jar后，有两种使用方案：

 方案一：把此jar拷贝到 ~/.android/lint/ 目录中（文件名任意）。此时，这些lint规则针对所有项目生效。

方案二：继续创建一个Android library项目，用来输出包含lint.jar的aar；然后，让目标项目依赖此aar即可使自定义lint规则生效。

由于方案一是全局生效的策略，无法单独针对目标项目，用处不大。在工程实践中，我们主要使用方案二。

自定义lint规则是以jar形式存在的，主要通过继承两种类来实现扩展lint功能：

* 1 新建java工程.

* 2 自定义lint规则需要继承一些特定的类，所以需要在build.gradle中添加依赖:
  compile 'com.android.tools.lint:lint-api:24.3.1'
  compile 'com.android.tools.lint:lint-checks:24.3.1'

* 3 ①继承IssueRegistry：这是自定义Lint规则的主类或者叫注册类，有且仅有一个，用来注册这个自定义Lint项目中有哪些自定义的issue
  （issue就是需要lint检查出来并报告给用户的各种问题）需要被检测。

  ②继承Detector并选择Detector中合适的XXXScanner接口来实现：在这里根据自身业务需求，实现各种自定义探测器（Detector),
  并定义各种issue，根据自身需求的不同这样的类可以有一个或多个。

* 4  对于自定义lint生成的jar，我们必须在它的清单文件中指明它的主类。这里我们通过配置ljflintrules的build.gradle文件来完成这项工作.
   jar {
       manifest {
           attributes('Lint-Registry': 'com.ljf.lintrules.MyIssueRegistry')
       }
   }

* 5 控制台中通过命令./gradlew ljflintrules:assemble来执行编译任务，就可以输出我们需要的jar文件了。
  你可以在ljflintrules工程目录的build/libs/下找到xxx.jar。
* 6 新建一个Android Library项目，命名为ljflintrule_aar，用来输出aar，步骤如下：
  在build.gradle的根节点加入以下内容：
  /*
   * rules for including "lint.jar" in aar
   */
  configurations {
      lintJarImport
  }

  dependencies {
      lintJarImport project(path: ":ljflintrules", configuration: "lintJarOutput")
  }

  task copyLintJar(type: Copy) {
      from (configurations.lintJarImport) {
          rename {
              String fileName ->
                  'lint.jar'
          }
      }
      into 'build/intermediates/lint/'
  }

  project.afterEvaluate {
      def compileLintTask = project.tasks.find { it.name == 'compileLint' }
      compileLintTask.dependsOn(copyLintJar)
  }
* 7 在用户app中使用我们的自定义lint。
  在用户自己的应用程序module中（我们这里就使用app module），打开app的build.gradle文件，在dependencies中加入以下依赖：
  compile project(':ljflintrule_aar')

