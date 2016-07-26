package com.example;

import com.android.annotations.NonNull;
import com.android.tools.lint.detector.api.Category;
import com.android.tools.lint.detector.api.ClassContext;
import com.android.tools.lint.detector.api.Detector;
import com.android.tools.lint.detector.api.Implementation;
import com.android.tools.lint.detector.api.Issue;
import com.android.tools.lint.detector.api.Scope;
import com.android.tools.lint.detector.api.Severity;
import org.objectweb.asm.tree.ClassNode;
import org.objectweb.asm.tree.MethodInsnNode;
import org.objectweb.asm.tree.MethodNode;
import java.util.Arrays;
import java.util.List;

/**
 * Created by Diablo on 16/7/25.
 */
public class LoggerUsageDetector extends Detector implements Detector.ClassScanner{
    /**
     * 这段代码中，我们定义了一个ISSUE，定义时传入的6个参数意义如下：
     LogUtilsNotUseds: 我们这条lint规则的id，这个id必须是独一无二的。
     You must use our 'LogUtils'：对这条lint规则的简短描述。
     Logging should be avoided in production for security and performance reasons. Therefore,
     we created a LogUtils that wraps all our calls to Logger and disable them for release flavor.：
     对这条lint规则更详细的解释。
     Category.MESSAGES：类别。
     9：优先级，必须在1到10之间。
     Severity.ERROR：严重程度。其他可用的严重程度还有FATAL、WARNING、INFORMATIONAL、IGNORE。
     Implementation：这是连接Detector与Scope的桥梁，其中Detector的功能是寻找issue，而scope定义了在什么范围内查找issue。在我们的例子中，我们需要在字节码级别分析用户有没有使用android.util.Log。
     */
    public static final Issue ISSUE = Issue.create("LogUtilsNotUsed",
            "You must use our `LogUtils`",
            "Logging should be avoided in production for security and performance reasons. Therefore, we created a LogUtils that wraps all our calls to Logger and disable them for release flavor.",
            Category.MESSAGES,
            9,
            Severity.ERROR,
            new Implementation(LoggerUsageDetector.class,
                    Scope.CLASS_FILE_SCOPE));

    @Override
    public List<String> getApplicableCallNames() {
        return Arrays.asList("v", "d", "i", "w", "e", "wtf");
    }

    @Override
    public List<String> getApplicableMethodNames() {
        return Arrays.asList("v", "d", "i", "w", "e", "wtf");
    }

    @Override
    public void checkCall(@NonNull ClassContext context,
                          @NonNull ClassNode classNode,
                          @NonNull MethodNode method,
                          @NonNull MethodInsnNode call) {
        String owner = call.owner;
        if (owner.startsWith("android/util/Log")) {
            context.report(ISSUE,
                    method,
                    call,
                    context.getLocation(call),
                    "You must use our `LogUtils`");
        }
    }
}
