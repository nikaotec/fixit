# Fixit Design System - Flutter Implementation

This document describes the Flutter implementation of the Fixit Light Style Guide v1.0.

## Overview

The Fixit design system provides a comprehensive set of design tokens, components, and guidelines for building consistent and beautiful user interfaces. This implementation is based on Material Design 3 with custom theming.

## Structure

The design system is organized into the following files:

```
lib/theme/
├── app_colors.dart       # Color palette and semantic colors
├── app_typography.dart   # Typography styles and font definitions
└── app_theme.dart        # Complete theme configuration

lib/widgets/
└── design_system_widgets.dart  # Reusable UI components
```

## Color Palette

### Brand & Semantic Colors

| Color | Hex Code | Usage |
|-------|----------|-------|
| **Brand Blue** | `#2196F3` | Primary actions, links, focus states |
| **Success Green** | `#4CAF50` | Success messages, completed states |
| **Warning Amber** | `#FFB300` | Warning messages, pending states |
| **Danger Red** | `#F44336` | Error messages, destructive actions |

### Neutral Colors

The design system uses a slate color palette for neutral elements:

- **Background Light**: `#F5F7F8` - Main app background
- **Surface Light**: `#FFFFFF` - Cards, dialogs, app bar
- **Text Primary**: `#0D151C` - Main text content
- **Text Secondary**: `#49779C` - Secondary text, labels
- **Text Tertiary**: `#64748B` - Captions, disabled text

### Status Badge Colors

Pre-defined color combinations for status badges:

- **Completed**: Green background (`#DCFCE7`) with dark green text (`#15803D`)
- **Pending**: Amber background (`#FEF3C7`) with dark amber text (`#A16207`)
- **In Progress**: Blue background (`#DBEAFE`) with dark blue text (`#1D4ED8`)
- **Failed**: Red background (`#FEE2E2`) with dark red text (`#B91C1C`)

## Typography

The design system uses the **Inter** font family throughout the application.

### Font Weights

- Regular: 400
- Medium: 500
- Semi-Bold: 600
- Bold: 700

### Text Styles

#### Headlines

```dart
// Headline 1 - Large, bold headlines (30px, bold)
AppTypography.headline1

// Headline 2 - Section headers (22px, bold)
AppTypography.headline2

// Headline 3 - Subsection headers (20px, semi-bold)
AppTypography.headline3
```

#### Body Text

```dart
// Body Text - Regular content (16px, regular)
AppTypography.bodyText

// Body Text Small (14px, regular)
AppTypography.bodyTextSmall

// Caption - Small descriptive text (14px, regular)
AppTypography.caption

// Caption Small (12px, regular)
AppTypography.captionSmall
```

#### Interactive Elements

```dart
// Button Text (16px, semi-bold)
AppTypography.button

// Button Text Small (14px, semi-bold)
AppTypography.buttonSmall

// Label - Form labels (14px, medium)
AppTypography.label

// Badge Text (12px, bold, uppercase)
AppTypography.badge

// Overline - Small uppercase labels (10px, bold, letter-spacing: 1.5)
AppTypography.overline
```

## Components

### Buttons

The theme provides three button styles:

#### Primary Button (ElevatedButton)

```dart
ElevatedButton(
  onPressed: () {},
  child: Text('Primary Action'),
)
```

- Background: Brand Blue (`#2196F3`)
- Text: White
- Border Radius: 12px
- Padding: 24px horizontal, 12px vertical

#### Secondary Button (FilledButton)

```dart
FilledButton(
  onPressed: () {},
  child: Text('Secondary Action'),
)
```

- Background: Slate 100 (`#F1F5F9`)
- Text: Dark (`#0D151C`)
- Border Radius: 12px
- Padding: 24px horizontal, 12px vertical

#### Text Button

```dart
TextButton(
  onPressed: () {},
  child: Text('Text Action'),
)
```

- Text: Brand Blue
- Border Radius: 8px
- No background

### Status Badges

Use the `StatusBadge` widget for displaying status:

```dart
StatusBadge(
  label: 'Completed',
  type: StatusType.completed,
)

StatusBadge(
  label: 'Pending',
  type: StatusType.pending,
)

StatusBadge(
  label: 'In Progress',
  type: StatusType.inProgress,
)

StatusBadge(
  label: 'Failed',
  type: StatusType.failed,
)
```

### Input Fields

Input fields follow Material Design 3 guidelines with custom styling:

```dart
TextField(
  decoration: InputDecoration(
    labelText: 'Email Address',
    hintText: 'hello@fixit.com',
  ),
)
```

Features:
- Border Radius: 12px
- Border Color: Slate 200 (`#E2E8F0`)
- Focus Border: Brand Blue, 2px width
- Padding: 16px horizontal, 12px vertical
- Background: White

### Cards

```dart
Card(
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Text('Card Content'),
  ),
)
```

Features:
- Border Radius: 12px
- Border: 1px solid Slate 100
- No elevation (flat design)
- Background: White

### Section Headers

Use the `SectionHeader` widget for consistent section headers:

```dart
SectionHeader(
  title: 'Typography',
  subtitle: 'Font Family: Inter',
)
```

### Description Lists

For key-value pairs, use the `DescriptionListItem` widget:

```dart
DescriptionListItem(
  label: 'Brand Blue',
  value: '#2196F3',
)
```

### Overline Labels

For small uppercase category labels:

```dart
OverlineLabel(
  text: 'Headline 1',
  color: AppColors.primary,
)
```

## Icons

The design system uses Material Symbols Outlined icons. In Flutter, use the standard Material Icons:

```dart
Icon(
  Icons.home,
  color: AppColors.primary,
  size: 24,
)
```

Common icon sizes:
- Small: 20px
- Default: 24px
- Large: 28px

## Border Radius

Standard border radius values:

- **Small**: 4px - Checkboxes, small chips
- **Default**: 8px - Text buttons, list tiles
- **Medium**: 12px - Buttons, input fields, cards
- **Large**: 16px - Dialogs, bottom sheets
- **Full**: 999px - Pills, badges, circular buttons

## Spacing

Use consistent spacing throughout the app:

- **4px**: Tight spacing between related elements
- **8px**: Default spacing within components
- **12px**: Spacing between form fields
- **16px**: Page margins, card padding
- **24px**: Section spacing
- **32px**: Large section spacing

## Elevation & Shadows

The design system uses minimal elevation:

- **0**: Cards, buttons (flat design)
- **4**: Floating action buttons, snackbars
- **8**: Dialogs, bottom navigation bar

## Usage Example

Here's a complete example of a screen using the design system:

```dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/design_system_widgets.dart';

class ExampleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Screen Title'),
            Text(
              'Subtitle',
              style: AppTypography.captionSmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Section Title',
              subtitle: 'Section description',
            ),
            
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // Status badges
                  Row(
                    children: [
                      StatusBadge(
                        label: 'Completed',
                        type: StatusType.completed,
                      ),
                      SizedBox(width: 8),
                      StatusBadge(
                        label: 'Pending',
                        type: StatusType.pending,
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Input field
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      hintText: 'hello@fixit.com',
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Buttons
                  ElevatedButton(
                    onPressed: () {},
                    child: Text('Primary Action'),
                  ),
                  
                  SizedBox(height: 12),
                  
                  FilledButton(
                    onPressed: () {},
                    child: Text('Secondary Action'),
                  ),
                ],
              ),
            ),
            
            // Description list
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  DescriptionListItem(
                    label: 'Brand Blue',
                    value: '#2196F3',
                  ),
                  DescriptionListItem(
                    label: 'Success Green',
                    value: '#4CAF50',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Best Practices

1. **Always use design tokens**: Use `AppColors` and `AppTypography` constants instead of hardcoded values.

2. **Consistent spacing**: Use multiples of 4px for spacing (4, 8, 12, 16, 24, 32).

3. **Semantic colors**: Use semantic colors (success, warning, danger) for their intended purposes.

4. **Typography hierarchy**: Maintain clear visual hierarchy using the predefined text styles.

5. **Accessibility**: Ensure sufficient color contrast (WCAG AA minimum).

6. **Reusable components**: Use the provided widgets (`StatusBadge`, `SectionHeader`, etc.) for consistency.

7. **Icons**: Use Material Icons with the primary color for interactive elements.

## Migration Guide

To apply the theme to an existing app:

1. Import the theme in your `main.dart`:
   ```dart
   import 'theme/app_theme.dart';
   ```

2. Apply the theme to `MaterialApp`:
   ```dart
   MaterialApp(
     theme: AppTheme.lightTheme,
     // ... other properties
   )
   ```

3. Replace hardcoded colors with `AppColors` constants.

4. Replace hardcoded text styles with `AppTypography` constants.

5. Update custom widgets to use theme-provided styles.

## Future Enhancements

Planned additions to the design system:

- Dark theme implementation
- Animation guidelines
- Accessibility utilities
- Additional component variants
- Responsive breakpoints
