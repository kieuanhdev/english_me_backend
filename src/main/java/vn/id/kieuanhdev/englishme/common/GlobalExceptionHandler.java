package vn.id.kieuanhdev.englishme.common;

import jakarta.servlet.http.HttpServletRequest;
import java.time.Instant;
import java.util.LinkedHashMap;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class GlobalExceptionHandler {
	@ExceptionHandler(MethodArgumentNotValidException.class)
	public ResponseEntity<ApiError> handleValidation(MethodArgumentNotValidException ex, HttpServletRequest req) {
		var fieldErrors = new LinkedHashMap<String, String>();
		for (FieldError fe : ex.getBindingResult().getFieldErrors()) {
			fieldErrors.putIfAbsent(fe.getField(), fe.getDefaultMessage());
		}
		return ResponseEntity.badRequest().body(ApiError.builder()
			.timestamp(Instant.now())
			.status(HttpStatus.BAD_REQUEST.value())
			.error(HttpStatus.BAD_REQUEST.getReasonPhrase())
			.message("Validation failed")
			.path(req.getRequestURI())
			.fieldErrors(fieldErrors)
			.build());
	}

	@ExceptionHandler(BadCredentialsException.class)
	public ResponseEntity<ApiError> handleBadCredentials(BadCredentialsException ex, HttpServletRequest req) {
		return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(ApiError.builder()
			.timestamp(Instant.now())
			.status(HttpStatus.UNAUTHORIZED.value())
			.error(HttpStatus.UNAUTHORIZED.getReasonPhrase())
			.message("Invalid credentials")
			.path(req.getRequestURI())
			.fieldErrors(null)
			.build());
	}

	@ExceptionHandler(AuthenticationException.class)
	public ResponseEntity<ApiError> handleAuth(AuthenticationException ex, HttpServletRequest req) {
		return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(ApiError.builder()
			.timestamp(Instant.now())
			.status(HttpStatus.UNAUTHORIZED.value())
			.error(HttpStatus.UNAUTHORIZED.getReasonPhrase())
			.message("Unauthorized")
			.path(req.getRequestURI())
			.fieldErrors(null)
			.build());
	}

	@ExceptionHandler(AccessDeniedException.class)
	public ResponseEntity<ApiError> handleDenied(AccessDeniedException ex, HttpServletRequest req) {
		return ResponseEntity.status(HttpStatus.FORBIDDEN).body(ApiError.builder()
			.timestamp(Instant.now())
			.status(HttpStatus.FORBIDDEN.value())
			.error(HttpStatus.FORBIDDEN.getReasonPhrase())
			.message("Forbidden")
			.path(req.getRequestURI())
			.fieldErrors(null)
			.build());
	}

	@ExceptionHandler(IllegalArgumentException.class)
	public ResponseEntity<ApiError> handleIllegalArgument(IllegalArgumentException ex, HttpServletRequest req) {
		return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(ApiError.builder()
			.timestamp(Instant.now())
			.status(HttpStatus.BAD_REQUEST.value())
			.error(HttpStatus.BAD_REQUEST.getReasonPhrase())
			.message(ex.getMessage())
			.path(req.getRequestURI())
			.fieldErrors(null)
			.build());
	}

	@ExceptionHandler(Exception.class)
	public ResponseEntity<ApiError> handleGeneric(Exception ex, HttpServletRequest req) {
		return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(ApiError.builder()
			.timestamp(Instant.now())
			.status(HttpStatus.INTERNAL_SERVER_ERROR.value())
			.error(HttpStatus.INTERNAL_SERVER_ERROR.getReasonPhrase())
			.message("Unexpected error")
			.path(req.getRequestURI())
			.fieldErrors(null)
			.build());
	}
}

