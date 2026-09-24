package com.fenglin.springboottest.common;

/**
 * 业务异常：用于向前端返回可读的错误提示（如“用户名已被注册”）。
 */
public class BusinessException extends RuntimeException {

    private static final int DEFAULT_CODE = 400;

    private final int code;

    public BusinessException(String message) {
        super(message);
        this.code = DEFAULT_CODE;
    }

    public BusinessException(int code, String message) {
        super(message);
        this.code = code;
    }

    public int getCode() {
        return code;
    }
}
