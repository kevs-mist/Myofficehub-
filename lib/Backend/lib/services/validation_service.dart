import 'dart:core';

class ValidationService {
  static ValidationService? _instance;
  static ValidationService get instance => _instance ??= ValidationService._();

  ValidationService._();

  // Validate tenant data
  Map<String, String> validateTenant(Map<String, dynamic> data) {
    final errors = <String, String>{};

    // Email validation
    final email = data['email'] as String?;
    if (email == null || email.isEmpty) {
      errors['email'] = 'Email is required';
    } else if (!_isValidEmail(email)) {
      errors['email'] = 'Invalid email format';
    }

    // Display name validation
    final displayName = data['display_name'] as String?;
    if (displayName == null || displayName.isEmpty) {
      errors['display_name'] = 'Display name is required';
    } else if (displayName.length < 2) {
      errors['display_name'] = 'Display name must be at least 2 characters';
    } else if (displayName.length > 255) {
      errors['display_name'] = 'Display name must not exceed 255 characters';
    }

    // Office number validation
    final officeNumber = data['office_number'] as String?;
    if (officeNumber != null && officeNumber.isNotEmpty) {
      if (officeNumber.length > 50) {
        errors['office_number'] = 'Office number must not exceed 50 characters';
      }
    }

    // Phone validation
    final phone = data['phone'] as String?;
    if (phone != null && phone.isNotEmpty) {
      if (!_isValidPhone(phone)) {
        errors['phone'] = 'Invalid phone number format';
      }
    }

    // Role validation
    final role = data['role'] as String?;
    if (role != null && role.isNotEmpty) {
      if (!['admin', 'tenant'].contains(role)) {
        errors['role'] = 'Role must be either admin or tenant';
      }
    }

    return errors;
  }

  // Validate event data
  Map<String, String> validateEvent(Map<String, dynamic> data) {
    final errors = <String, String>{};

    // Title validation
    final title = data['title'] as String?;
    if (title == null || title.isEmpty) {
      errors['title'] = 'Title is required';
    } else if (title.length < 3) {
      errors['title'] = 'Title must be at least 3 characters';
    } else if (title.length > 255) {
      errors['title'] = 'Title must not exceed 255 characters';
    }

    // Description validation
    final description = data['description'] as String?;
    if (description != null && description.length > 1000) {
      errors['description'] = 'Description must not exceed 1000 characters';
    }

    // Event date validation
    final eventDate = data['event_date'] as String?;
    if (eventDate != null && eventDate.isNotEmpty) {
      if (!_isValidDateTime(eventDate)) {
        errors['event_date'] =
            'Invalid date format. Use ISO 8601 format (e.g., 2026-02-15T10:00:00Z)';
      }
    }

    // Location validation
    final location = data['location'] as String?;
    if (location != null && location.length > 255) {
      errors['location'] = 'Location must not exceed 255 characters';
    }

    // Event type validation
    final eventType = data['event_type'] as String?;
    if (eventType != null && eventType.isNotEmpty) {
      if (!['meeting', 'announcement', 'maintenance', 'social', 'general']
          .contains(eventType)) {
        errors['event_type'] =
            'Event type must be one of: meeting, announcement, maintenance, social, general';
      }
    }

    return errors;
  }

  // Validate complaint data
  Map<String, String> validateComplaint(Map<String, dynamic> data) {
    final errors = <String, String>{};

    // Title validation
    final title = data['title'] as String?;
    if (title == null || title.isEmpty) {
      errors['title'] = 'Title is required';
    } else if (title.length < 3) {
      errors['title'] = 'Title must be at least 3 characters';
    } else if (title.length > 255) {
      errors['title'] = 'Title must not exceed 255 characters';
    }

    // Description validation
    final description = data['description'] as String?;
    if (description == null || description.isEmpty) {
      errors['description'] = 'Description is required';
    } else if (description.length < 10) {
      errors['description'] = 'Description must be at least 10 characters';
    } else if (description.length > 2000) {
      errors['description'] = 'Description must not exceed 2000 characters';
    }

    // Category validation
    final category = data['category'] as String?;
    if (category != null && category.isNotEmpty) {
      if (![
        'maintenance',
        'noise',
        'security',
        'cleanliness',
        'parking',
        'general'
      ].contains(category)) {
        errors['category'] =
            'Category must be one of: maintenance, noise, security, cleanliness, parking, general';
      }
    }

    // Priority validation
    final priority = data['priority'] as String?;
    if (priority != null && priority.isNotEmpty) {
      if (!['low', 'medium', 'high', 'urgent'].contains(priority)) {
        errors['priority'] =
            'Priority must be one of: low, medium, high, urgent';
      }
    }

    // Status validation
    final status = data['status'] as String?;
    if (status != null && status.isNotEmpty) {
      if (!['open', 'in_progress', 'resolved', 'closed'].contains(status)) {
        errors['status'] =
            'Status must be one of: open, in_progress, resolved, closed';
      }
    }

    return errors;
  }

  // Validate payment data
  Map<String, String> validatePayment(Map<String, dynamic> data) {
    final errors = <String, String>{};

    // Amount validation
    final amount = data['amount'] as String?;
    if (amount == null || amount.isEmpty) {
      errors['amount'] = 'Amount is required';
    } else {
      try {
        final amountValue = double.parse(amount);
        if (amountValue <= 0) {
          errors['amount'] = 'Amount must be greater than 0';
        } else if (amountValue > 999999.99) {
          errors['amount'] = 'Amount must not exceed 999999.99';
        }
      } catch (e) {
        errors['amount'] = 'Invalid amount format';
      }
    }

    // Payment type validation
    final paymentType = data['payment_type'] as String?;
    if (paymentType != null && paymentType.isNotEmpty) {
      if (!['rent', 'maintenance', 'utilities', 'other']
          .contains(paymentType)) {
        errors['payment_type'] =
            'Payment type must be one of: rent, maintenance, utilities, other';
      }
    }

    // Status validation
    final status = data['status'] as String?;
    if (status != null && status.isNotEmpty) {
      if (!['pending', 'paid', 'overdue', 'cancelled'].contains(status)) {
        errors['status'] =
            'Status must be one of: pending, paid, overdue, cancelled';
      }
    }

    // Due date validation
    final dueDate = data['due_date'] as String?;
    if (dueDate != null && dueDate.isNotEmpty) {
      if (!_isValidDate(dueDate)) {
        errors['due_date'] = 'Invalid date format. Use YYYY-MM-DD format';
      }
    }

    // Paid date validation
    final paidDate = data['paid_date'] as String?;
    if (paidDate != null && paidDate.isNotEmpty) {
      if (!_isValidDate(paidDate)) {
        errors['paid_date'] = 'Invalid date format. Use YYYY-MM-DD format';
      }
    }

    // Description validation
    final description = data['description'] as String?;
    if (description != null && description.length > 500) {
      errors['description'] = 'Description must not exceed 500 characters';
    }

    // Payment method validation
    final paymentMethod = data['payment_method'] as String?;
    if (paymentMethod != null && paymentMethod.isNotEmpty) {
      if (!['cash', 'card', 'bank_transfer', 'online', 'check']
          .contains(paymentMethod)) {
        errors['payment_method'] =
            'Payment method must be one of: cash, card, bank_transfer, online, check';
      }
    }

    return errors;
  }

  // Email validation regex
  bool _isValidEmail(String email) {
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  // Phone validation regex (basic)
  bool _isValidPhone(String phone) {
    final phoneRegex = RegExp(r'^[\d\s\-\+\(\)]+$');
    return phoneRegex.hasMatch(phone) &&
        phone.replaceAll(RegExp(r'[\s\-\+\(\)]'), '').length >= 10;
  }

  // Date validation (YYYY-MM-DD)
  bool _isValidDate(String date) {
    try {
      final dateTime = DateTime.parse(date);
      return dateTime.year >= 1900 && dateTime.year <= 2100;
    } catch (e) {
      return false;
    }
  }

  // DateTime validation (ISO 8601)
  bool _isValidDateTime(String dateTime) {
    try {
      DateTime.parse(dateTime);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Validate UUID format
  bool _isValidUUID(String uuid) {
    final uuidRegex = RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
    return uuidRegex.hasMatch(uuid);
  }

  // Validate tenant ID
  Map<String, String> validateTenantId(String tenantId) {
    final errors = <String, String>{};

    if (tenantId.isEmpty) {
      errors['tenant_id'] = 'Tenant ID is required';
    } else if (!_isValidUUID(tenantId)) {
      errors['tenant_id'] = 'Invalid tenant ID format';
    }

    return errors;
  }

  // Validate update data (partial updates)
  Map<String, String> validateUpdateData(
      Map<String, dynamic> data, String resourceType) {
    switch (resourceType) {
      case 'tenant':
        return validateTenant(data);
      case 'event':
        return validateEvent(data);
      case 'complaint':
        return validateComplaint(data);
      case 'payment':
        return validatePayment(data);
      default:
        return {'resource_type': 'Unknown resource type'};
    }
  }

  // Sanitize input data
  Map<String, dynamic> sanitizeData(Map<String, dynamic> data) {
    final sanitized = <String, dynamic>{};

    for (final entry in data.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value is String) {
        // Trim whitespace and remove potential XSS
        sanitized[key] = value.trim().replaceAll(RegExp(r'<[^>]*>'), '');
      } else if (value is num) {
        sanitized[key] = value;
      } else if (value is bool) {
        sanitized[key] = value;
      } else if (value is Map) {
        sanitized[key] = sanitizeData(value as Map<String, dynamic>);
      } else if (value is List) {
        sanitized[key] = value
            .map((item) =>
                item is Map ? sanitizeData(item as Map<String, dynamic>) : item)
            .toList();
      } else {
        sanitized[key] = value;
      }
    }

    return sanitized;
  }

  // Validate required fields
  Map<String, String> validateRequiredFields(
      Map<String, dynamic> data, List<String> requiredFields) {
    final errors = <String, String>{};

    for (final field in requiredFields) {
      if (!data.containsKey(field) ||
          data[field] == null ||
          (data[field] is String && (data[field] as String).isEmpty)) {
        errors[field] = '$field is required';
      }
    }

    return errors;
  }

  // Validate pagination parameters
  Map<String, String> validatePaginationParams(Map<String, dynamic> params) {
    final errors = <String, String>{};

    // Page validation
    final page = params['page'] as String?;
    if (page != null && page.isNotEmpty) {
      try {
        final pageNum = int.parse(page);
        if (pageNum < 1) {
          errors['page'] = 'Page must be greater than 0';
        }
      } catch (e) {
        errors['page'] = 'Invalid page format';
      }
    }

    // Limit validation
    final limit = params['limit'] as String?;
    if (limit != null && limit.isNotEmpty) {
      try {
        final limitNum = int.parse(limit);
        if (limitNum < 1 || limitNum > 100) {
          errors['limit'] = 'Limit must be between 1 and 100';
        }
      } catch (e) {
        errors['limit'] = 'Invalid limit format';
      }
    }

    return errors;
  }
}
