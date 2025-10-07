# Supabase Setup Instructions

## 🚀 Quick Setup Guide

### 1. Create a Supabase Project
1. Go to [supabase.com](https://supabase.com)
2. Sign up/Login to your account
3. Click "New Project"
4. Choose your organization and enter project details
5. Wait for the project to be created

### 2. Get Your Project Credentials
1. In your Supabase dashboard, go to **Settings** → **API**
2. Copy your **Project URL** and **anon/public key**
3. Update `lib/config/supabase_config.dart` with your credentials:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'https://your-project-id.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
}
```

### 3. Set Up Database Schema
1. In your Supabase dashboard, go to **SQL Editor**
2. Copy the contents of `supabase_schema.sql`
3. Paste and run the SQL script
4. This will create all necessary tables and insert sample data

### 4. Install Dependencies
Run the following command in your project root:
```bash
flutter pub get
```

### 5. Test the Integration
1. Run your Flutter app: `flutter run`
2. The app should now connect to Supabase instead of using mock data
3. Check your Supabase dashboard to see data being created/updated

## 📊 Database Tables Created

The schema creates the following tables:
- `customers` - Customer information and spending data
- `reviews` - Customer reviews and ratings
- `menu_items` - Restaurant menu items
- `staff` - Staff member information
- `drivers` - Delivery driver information
- `promotions` - Promotional codes and discounts
- `orders` - Order information
- `order_items` - Individual items within orders

## 🔒 Security Features

- **Row Level Security (RLS)** enabled on all tables
- **Policies** configured to allow authenticated operations
- **Indexes** created for optimal query performance

## 🛠️ Customization

### Adding Authentication
To add user authentication, you can:
1. Enable authentication in Supabase dashboard
2. Update RLS policies to be user-specific
3. Add authentication logic to your repositories

### Modifying Tables
To modify table structures:
1. Update the SQL schema in `supabase_schema.sql`
2. Update corresponding model classes in `lib/models/`
3. Update repository methods if needed

## 🐛 Troubleshooting

### Common Issues:

1. **Connection Failed**
   - Check your Supabase URL and API key
   - Ensure your Supabase project is active

2. **Table Not Found**
   - Run the SQL schema script in Supabase SQL Editor
   - Check table names match between schema and repositories

3. **Permission Denied**
   - Verify RLS policies are correctly set up
   - Check if authentication is required

4. **Data Not Appearing**
   - Check Supabase dashboard for any errors
   - Verify your app is using the correct table names

## 📱 Next Steps

1. **Add Authentication**: Implement user login/signup
2. **Real-time Updates**: Use Supabase real-time features
3. **File Storage**: Add image upload for menu items
4. **Advanced Queries**: Implement complex filtering and search
5. **Analytics**: Add database-level analytics queries

## 🔗 Useful Links

- [Supabase Documentation](https://supabase.com/docs)
- [Flutter Supabase Guide](https://supabase.com/docs/guides/getting-started/tutorials/with-flutter)
- [Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)
