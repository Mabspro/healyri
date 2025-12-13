import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme.dart';

/// A class representing a slide in the intro carousel
class IntroSlide {
  final String title;
  final String description;
  final String? image;

  IntroSlide({
    required this.title,
    required this.description,
    this.image,
  });
}

/// A collection of reusable UI components with enhanced styling
/// based on the HeaLyri design system.
class AppComponents {
  /// Creates a logo widget with the HeaLyri branding
  /// Updated to use a text-based logo with color gradient and heart icon
  static Widget logo({
    double size = 36,
    bool showIcon = true,
    MainAxisAlignment alignment = MainAxisAlignment.center,
    Color? backgroundColor,
  }) {
    return Builder(
      builder: (context) {
        // Define gradient colors for the text
        const blueColor = Color(0xFF1976D2); // Blue
        const purpleColor = Color(0xFF7E57C2); // Purple
        const orangeColor = Color(0xFFFF7043); // Orange-red
        
        // Use a white background with higher opacity to make the logo stand out
        final bgColor = backgroundColor ?? Colors.white.withOpacity(0.85);
        
        return Center(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: size * 0.6,
              vertical: size * 0.4,
            ),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(size * 0.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showIcon)
                  // Heart icon with plus sign
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.favorite,
                        color: blueColor,
                        size: size * 1.2,
                      ),
                      Icon(
                        Icons.add,
                        color: Colors.white,
                        size: size * 0.6,
                      ),
                    ],
                  ),
                if (showIcon)
                  SizedBox(height: size * 0.4),
                // Text with gradient
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [blueColor, purpleColor, orangeColor],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ).createShader(bounds),
                  child: Text(
                    'HeaLyri',
                    style: TextStyle(
                      color: Colors.white, // This will be replaced by the gradient
                      fontSize: size * 0.8, // Slightly smaller text
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  /// Creates an app icon for use in app launcher, splash screen, etc.
  static Widget appIcon({
    double size = 60,
    Color? primaryColor,
    Color? accentColor,
  }) {
    return Builder(
      builder: (context) {
        final primary = primaryColor ?? AppTheme.primaryColor;
        final accent = accentColor ?? AppTheme.accentColor;
        
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primary, accent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(size * 0.2),
            boxShadow: [
              BoxShadow(
                color: primary.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // "H" part
              Positioned(
                left: size * 0.25,
                child: Text(
                  'H',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size * 0.5,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // "L" part - overlapping with H
              Positioned(
                right: size * 0.25,
                child: Text(
                  'L',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: size * 0.5,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Creates a gradient button with enhanced styling
  static Widget gradientButton({
    required String text,
    required VoidCallback onPressed,
    List<Color>? gradientColors,
    double borderRadius = 30,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    bool isLoading = false,
    IconData? icon,
    bool fullWidth = false,
  }) {
    return Builder(
      builder: (context) {
        final colors = gradientColors ?? AppTheme.primaryGradient;
        
        return MouseRegion(
          cursor: isLoading ? SystemMouseCursors.basic : SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: fullWidth ? double.infinity : null,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                BoxShadow(
                  color: colors.first.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isLoading ? null : onPressed,
                borderRadius: BorderRadius.circular(borderRadius),
                splashColor: Colors.white.withOpacity(0.2),
                highlightColor: Colors.transparent,
                child: AnimatedPadding(
                  duration: const Duration(milliseconds: 200),
                  padding: padding,
                  child: Row(
                    mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isLoading)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      else if (icon != null) ...[
                        Icon(icon, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                      ],
                      if (!isLoading)
                        Text(
                          text,
                          style: AppTheme.buttonText.copyWith(
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Creates an outlined button with enhanced styling
  static Widget outlinedButton({
    required String text,
    required VoidCallback onPressed,
    Color? borderColor,
    Color? textColor,
    double borderRadius = 30,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    bool isLoading = false,
    IconData? icon,
    bool fullWidth = false,
  }) {
    return Builder(
      builder: (context) {
        final color = borderColor ?? AppTheme.primaryColor;
        final txtColor = textColor ?? color;
        
        return Container(
          width: fullWidth ? double.infinity : null,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: color),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isLoading ? null : onPressed,
              borderRadius: BorderRadius.circular(borderRadius),
              splashColor: color.withOpacity(0.1),
              highlightColor: Colors.transparent,
              child: Padding(
                padding: padding,
                child: Row(
                  mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isLoading)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      )
                    else if (icon != null) ...[
                      Icon(icon, color: txtColor, size: 20),
                      const SizedBox(width: 8),
                    ],
                    if (!isLoading)
                      Text(
                        text,
                        style: AppTheme.buttonText.copyWith(color: txtColor),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Creates an enhanced card with gradient accent and shadow
  static Widget enhancedCard({
    required Widget child,
    Color? backgroundColor,
    List<Color>? accentGradient,
    double borderRadius = 20,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    List<BoxShadow>? boxShadow,
    double accentHeight = 6,
    double accentWidth = 60,
    bool fullWidth = true,
    VoidCallback? onTap,
  }) {
    return Builder(
      builder: (context) {
        final colors = accentGradient ?? AppTheme.primaryGradient;
        final bgColor = backgroundColor ?? AppTheme.cardColor;
        final shadow = boxShadow ?? AppTheme.lightShadow;
        
        return MouseRegion(
          cursor: onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: fullWidth ? double.infinity : null,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: shadow,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(borderRadius),
                splashColor: colors.first.withOpacity(0.05),
                highlightColor: Colors.transparent,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(borderRadius),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: accentHeight,
                          width: accentWidth,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: colors,
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: colors.first.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                      AnimatedPadding(
                        duration: const Duration(milliseconds: 200),
                        padding: padding,
                        child: child,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Creates an enhanced input field with animation and custom styling
  static Widget enhancedTextField({
    required TextEditingController controller,
    String? labelText,
    String? hintText,
    IconData? prefixIcon,
    Widget? suffix,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    Function(String)? onChanged,
    Function(String)? onSubmitted,
    FocusNode? focusNode,
    bool autofocus = false,
    int? maxLines = 1,
    int? minLines,
    bool enabled = true,
    TextCapitalization textCapitalization = TextCapitalization.none,
    Color? accentColor,
  }) {
    return Builder(
      builder: (context) {
        final accent = accentColor ?? AppTheme.primaryColor;
        
        return TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          focusNode: focusNode,
          autofocus: autofocus,
          maxLines: maxLines,
          minLines: minLines,
          enabled: enabled,
          textCapitalization: textCapitalization,
          style: AppTheme.bodyText,
          decoration: InputDecoration(
            labelText: labelText,
            hintText: hintText,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
            suffixIcon: suffix,
            floatingLabelStyle: AppTheme.subtitle.copyWith(color: accent),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: accent, width: 2),
            ),
          ),
        );
      },
    );
  }

  /// Creates a search input field with voice input option
  static Widget searchField({
    required TextEditingController controller,
    String hintText = 'Search',
    Function(String)? onChanged,
    Function(String)? onSubmitted,
    VoidCallback? onVoiceSearch,
    FocusNode? focusNode,
    bool autofocus = false,
  }) {
    return Builder(
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppTheme.lightShadow,
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            focusNode: focusNode,
            autofocus: autofocus,
            style: AppTheme.bodyText,
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.mic),
                onPressed: onVoiceSearch,
                tooltip: 'Voice Search',
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        );
      },
    );
  }

  /// Creates a chip for selecting options
  static Widget selectionChip({
    required String label,
    required bool isSelected,
    required Function(bool) onSelected,
    Color? selectedColor,
    Color? backgroundColor,
    IconData? icon,
  }) {
    return Builder(
      builder: (context) {
        final selectedBg = selectedColor ?? AppTheme.primaryColor.withOpacity(0.15);
        final bg = backgroundColor ?? Colors.grey[100]!;
        
        return FilterChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
                ),
                const SizedBox(width: 4),
              ],
              Text(label),
            ],
          ),
          selected: isSelected,
          onSelected: onSelected,
          backgroundColor: bg,
          selectedColor: selectedBg,
          checkmarkColor: AppTheme.primaryColor,
          labelStyle: AppTheme.bodyText.copyWith(
            color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
            fontSize: 14,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: BorderSide(
              color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
              width: isSelected ? 1 : 0.5,
            ),
          ),
        );
      },
    );
  }

  /// Creates a section header with optional action button
  static Widget sectionHeader({
    required String title,
    String? actionText,
    VoidCallback? onActionPressed,
    CrossAxisAlignment alignment = CrossAxisAlignment.start,
  }) {
    return Builder(
      builder: (context) {
        return Column(
          crossAxisAlignment: alignment,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: AppTheme.heading3,
                ),
                if (actionText != null && onActionPressed != null)
                  TextButton(
                    onPressed: onActionPressed,
                    child: Text(
                      actionText,
                      style: AppTheme.subtitle.copyWith(
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  /// Creates a quick action card for the home screen
  static Widget quickActionCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    List<Color>? gradientColors,
    bool isEmergency = false,
  }) {
    return Builder(
      builder: (context) {
        final colors = isEmergency
            ? [Colors.red.shade700, Colors.red.shade500]
            : gradientColors ?? AppTheme.primaryGradient;
        
        return GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: colors.first.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: AppTheme.subtitle.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Creates an appointment card with status indicator
  static Widget appointmentCard({
    required String doctorName,
    required String specialty,
    required String facilityName,
    required DateTime dateTime,
    required String status,
    required VoidCallback onTap,
    String? imageUrl,
  }) {
    return Builder(
      builder: (context) {
        Color statusColor;
        switch (status.toLowerCase()) {
          case 'confirmed':
            statusColor = AppTheme.successColor;
            break;
          case 'pending':
            statusColor = AppTheme.warningColor;
            break;
          case 'cancelled':
            statusColor = AppTheme.errorColor;
            break;
          default:
            statusColor = AppTheme.infoColor;
        }
        
        return enhancedCard(
          onTap: onTap,
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
                      child: imageUrl == null
                          ? const Icon(Icons.person, size: 30, color: Colors.grey)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctorName,
                            style: AppTheme.heading4,
                          ),
                          Text(
                            specialty,
                            style: AppTheme.caption.copyWith(
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            facilityName,
                            style: AppTheme.bodyText.copyWith(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: AppTheme.textSecondaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${dateTime.day}/${dateTime.month}/${dateTime.year}',
                          style: AppTheme.bodyText.copyWith(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: AppTheme.textSecondaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}',
                          style: AppTheme.bodyText.copyWith(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: statusColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            status,
                            style: AppTheme.caption.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Creates a health metric card for the home screen
  static Widget healthMetricCard({
    required String title,
    required String value,
    required IconData icon,
    List<Color>? gradientColors,
  }) {
    return Builder(
      builder: (context) {
        final colors = gradientColors ?? [Colors.white, Colors.white];
        
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppTheme.lightShadow,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: AppTheme.heading4.copyWith(
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: AppTheme.caption,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
  
  /// Creates an empty state widget for when there's no data to display
  static Widget emptyState({
    required String message,
    String? actionText,
    VoidCallback? onAction,
    IconData icon = Icons.inbox_rounded,
    Color? iconColor,
    double iconSize = 64,
  }) {
    return Builder(
      builder: (context) {
        final color = iconColor ?? AppTheme.textSecondaryColor;
        
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: iconSize,
                  color: color.withOpacity(0.5),
                ),
                const SizedBox(height: 24),
                Text(
                  message,
                  style: AppTheme.subtitle.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (actionText != null && onAction != null) ...[
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: onAction,
                    child: Text(actionText),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
  
  /// Creates an intro carousel for onboarding
  static Widget introCarousel({
    required List<IntroSlide> slides,
    required Function(int) onPageChanged,
    required int currentPage,
    required VoidCallback onGetStarted,
    String getStartedText = 'Get Started',
    PageController? pageController,
  }) {
    return Builder(
      builder: (context) {
        // Create a local controller if none is provided
        final controller = pageController ?? PageController();
        
        // If currentPage changes externally, update the page view
        if (pageController == null && controller.hasClients && 
            controller.page?.round() != currentPage) {
          controller.animateToPage(
            currentPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
          );
        }
        
        return Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: controller,
                itemCount: slides.length,
                onPageChanged: onPageChanged,
                itemBuilder: (context, index) {
                  final slide = slides[index];
                  final isCurrentPage = index == currentPage;
                  
                  return AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: isCurrentPage ? 1.0 : 0.5,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (slide.image != null) ...[
                            AnimatedScale(
                              duration: const Duration(milliseconds: 500),
                              scale: isCurrentPage ? 1.0 : 0.8,
                              curve: Curves.easeOutCubic,
                              child: Image.asset(
                                slide.image!,
                                height: 220,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                          AnimatedSlide(
                            duration: const Duration(milliseconds: 500),
                            offset: Offset(isCurrentPage ? 0 : 0.2, 0),
                            curve: Curves.easeOutCubic,
                            child: Text(
                              slide.title,
                              style: AppTheme.heading2.copyWith(
                                height: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 16),
                          AnimatedSlide(
                            duration: const Duration(milliseconds: 500),
                            offset: Offset(isCurrentPage ? 0 : 0.2, 0),
                            curve: Curves.easeOutCubic,
                            child: Text(
                              slide.description,
                              style: AppTheme.bodyText.copyWith(
                                height: 1.5,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Page indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      slides.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutCubic,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: currentPage == index ? 24 : 8,
                        height: 6,
                        decoration: BoxDecoration(
                          color: currentPage == index
                              ? AppTheme.primaryColor
                              : AppTheme.primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: currentPage == index ? [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ] : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Get started button
                  AnimatedScale(
                    duration: const Duration(milliseconds: 300),
                    scale: currentPage == slides.length - 1 ? 1.0 : 0.95,
                    curve: Curves.easeOutCubic,
                    child: gradientButton(
                      text: getStartedText,
                      onPressed: onGetStarted,
                      fullWidth: true,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
