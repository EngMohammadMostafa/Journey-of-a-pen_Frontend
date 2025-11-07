
import React, { useState, useEffect } from 'react'
import DataTable from '../components/common/DataTable'
import Modal from '../components/common/Modal'
import { usersService } from '../services/usersService'
import { useAuth } from '../context/AuthContext'
import '../styles/UsersManagement.css'

const UsersManagement = () => {
  const [users, setUsers] = useState([]);
  const [filteredUsers, setFilteredUsers] = useState([]);
  const [loading, setLoading] = useState(false);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingUser, setEditingUser] = useState(null);
  const [searchTerm, setSearchTerm] = useState('');
  const [userTypeFilter, setUserTypeFilter] = useState('all');
  const { token } = useAuth();

  const [formData, setFormData] = useState({
    username: '',
    email: '',
    password: '',
    age: '',
    gender: 'male'
  });

  // أعمدة الجدول
  const columns = [
    { key: 'id', title: 'ID' },
    { key: 'username', title: 'اسم المستخدم' },
    { key: 'email', title: 'البريد الإلكتروني' },
    { 
      key: 'age', 
      title: 'العمر',
      render: (value) => value || 'غير محدد'
    },
    { 
      key: 'gender', 
      title: 'الجنس',
      render: (value) => {
        const genders = { male: 'ذكر', female: 'أنثى' };
        return genders[value] || value;
      }
    },
    { 
      key: 'user_type', 
      title: 'نوع المستخدم',
      render: (value) => value === 1 ? 'عادي' : 'مدير'
    },
    { key: 'points', title: 'النقاط' },
    { key: 'purchases_count', title: 'عدد المشتريات' }
  ];

  // جلب جميع المستخدمين
  const fetchUsers = async () => {
    setLoading(true);
    try {
      const response = await usersService.getAllUsers(token);
      setUsers(response.users || []);
      setFilteredUsers(response.users || []);
    } catch (error) {
      console.error('Error fetching users:', error);
      alert('حدث خطأ في جلب بيانات المستخدمين');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchUsers();
  }, []);

  // تصفية المستخدمين حسب البحث ونوع المستخدم
  useEffect(() => {
    let filtered = users;

    // التصفية حسب البحث
    if (searchTerm) {
      filtered = filtered.filter(user => 
        user.username?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        user.email?.toLowerCase().includes(searchTerm.toLowerCase())
      );
    }

    // التصفية حسب نوع المستخدم
    if (userTypeFilter !== 'all') {
      filtered = filtered.filter(user => user.user_type === parseInt(userTypeFilter));
    }

    setFilteredUsers(filtered);
  }, [users, searchTerm, userTypeFilter]);

  // إحصائيات المستخدمين
  const userStats = {
    total: users.length,
    regular: users.filter(u => u.user_type === 1).length,
    admin: users.filter(u => u.user_type === 2).length,
    withPurchases: users.filter(u => u.purchases_count > 0).length
  };

  // فتح مودال التعديل
  const handleEdit = (user) => {
    setEditingUser(user);
    setFormData({
      username: user.username || '',
      email: user.email || '',
      password: '', // لا نعرض كلمة المرور الحالية
      age: user.age || '',
      gender: user.gender || 'male'
    });
    setIsModalOpen(true);
  };

  // حذف مستخدم
  const handleDelete = async (user) => {
    if (window.confirm(`هل أنت متأكد من حذف المستخدم "${user.username}"؟`)) {
      try {
        await usersService.deleteUser(user.id, token);
        alert('تم حذف المستخدم بنجاح');
        fetchUsers(); // إعادة جلب البيانات
      } catch (error) {
        console.error('Error deleting user:', error);
        alert('حدث خطأ في حذف المستخدم');
      }
    }
  };

  // حفظ التعديلات
  const handleSave = async () => {
    try {
      const userData = { ...formData };
      // إذا لم يتم تغيير كلمة المرور، نحذفها من البيانات المرسلة
      if (!userData.password) {
        delete userData.password;
      }

      await usersService.updateUser(editingUser.id, userData, token);
      alert('تم تحديث بيانات المستخدم بنجاح');
      setIsModalOpen(false);
      setEditingUser(null);
      fetchUsers(); // إعادة جلب البيانات
    } catch (error) {
      console.error('Error updating user:', error);
      alert('حدث خطأ في تحديث بيانات المستخدم');
    }
  };

  // إضافة مستخدم جديد
  const handleAddUser = () => {
    setEditingUser(null);
    setFormData({
      username: '',
      email: '',
      password: '',
      age: '',
      gender: 'male'
    });
    setIsModalOpen(true);
  };

  // حفظ مستخدم جديد
  const handleSaveNewUser = async () => {
    try {
      // التحقق من البيانات المطلوبة
      if (!formData.username || !formData.email || !formData.password) {
        alert('الرجاء ملء جميع الحقول المطلوبة');
        return;
      }

      // هنا يمكنك إضافة استدعاء API لإضافة مستخدم جديد
      // await usersService.addUser(formData, token);
      alert('سيتم تفعيل إضافة المستخدم بعد اكتمال API');
      
      setIsModalOpen(false);
      setFormData({
        username: '',
        email: '',
        password: '',
        age: '',
        gender: 'male'
      });
    } catch (error) {
      console.error('Error adding user:', error);
      alert('حدث خطأ في إضافة المستخدم');
    }
  };

  const handleFormSubmit = editingUser ? handleSave : handleSaveNewUser;
  const modalTitle = editingUser ? 'تعديل بيانات المستخدم' : 'إضافة مستخدم جديد';

  return (
    <div className="users-management">
      <div className="page-header">
        <h1>إدارة المستخدمين</h1>
        <button className="btn-primary" onClick={handleAddUser}>
          + إضافة مستخدم
        </button>
      </div>

      {/* إحصائيات المستخدمين */}
      <div className="user-stats">
        <div className="stat-card">
          <h3>إجمالي المستخدمين</h3>
          <span className="stat-number">{userStats.total}</span>
        </div>
        <div className="stat-card">
          <h3>مستخدمين عاديين</h3>
          <span className="stat-number">{userStats.regular}</span>
        </div>
        <div className="stat-card">
          <h3>مديرين</h3>
          <span className="stat-number">{userStats.admin}</span>
        </div>
        <div className="stat-card">
          <h3>لديهم مشتريات</h3>
          <span className="stat-number">{userStats.withPurchases}</span>
        </div>
      </div>

      {/* شريط البحث والتصفية */}
      <div className="users-filters">
        <div className="search-section">
          <input
            type="text"
            placeholder="ابحث بالاسم أو البريد الإلكتروني..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="search-input"
          />
        </div>
        
        <div className="filter-section">
          <select 
            value={userTypeFilter} 
            onChange={(e) => setUserTypeFilter(e.target.value)}
            className="filter-select"
          >
            <option value="all">جميع المستخدمين</option>
            <option value="1">مستخدمين عاديين</option>
            <option value="2">مديرين</option>
          </select>
        </div>

        <div className="results-count">
          <span>عرض {filteredUsers.length} من أصل {users.length} مستخدم</span>
        </div>
      </div>

      {/* جدول البيانات */}
      <DataTable
        columns={columns}
        data={filteredUsers}
        loading={loading}
        onEdit={handleEdit}
        onDelete={handleDelete}
        actions={['edit', 'delete']}
      />

      {/* مودال إضافة/تعديل مستخدم */}
      <Modal
        isOpen={isModalOpen}
        onClose={() => {
          setIsModalOpen(false);
          setEditingUser(null);
        }}
        title={modalTitle}
      >
        <div className="user-form">
          <div className="form-group">
            <label>اسم المستخدم: *</label>
            <input
              type="text"
              value={formData.username}
              onChange={(e) => setFormData({ ...formData, username: e.target.value })}
              required
            />
          </div>
          
          <div className="form-group">
            <label>البريد الإلكتروني: *</label>
            <input
              type="email"
              value={formData.email}
              onChange={(e) => setFormData({ ...formData, email: e.target.value })}
              required
            />
          </div>
          
          <div className="form-group">
            <label>
              {editingUser ? 'كلمة المرور (اتركها فارغة إذا لم ترد التغيير):' : 'كلمة المرور: *'}
            </label>
            <input
              type="password"
              value={formData.password}
              onChange={(e) => setFormData({ ...formData, password: e.target.value })}
              placeholder={editingUser ? "اتركها فارغة للحفاظ على كلمة المرور الحالية" : "أدخل كلمة المرور"}
              required={!editingUser}
            />
          </div>
          
          <div className="form-group">
            <label>العمر:</label>
            <input
              type="number"
              value={formData.age}
              onChange={(e) => setFormData({ ...formData, age: e.target.value })}
              min="1"
              max="120"
            />
          </div>
          
          <div className="form-group">
            <label>الجنس:</label>
            <select
              value={formData.gender}
              onChange={(e) => setFormData({ ...formData, gender: e.target.value })}
            >
              <option value="male">ذكر</option>
              <option value="female">أنثى</option>
            </select>
          </div>

          {!editingUser && (
            <div className="form-group">
              <label>نوع المستخدم:</label>
              <select
                value={formData.user_type || '1'}
                onChange={(e) => setFormData({ ...formData, user_type: parseInt(e.target.value) })}
              >
                <option value="1">مستخدم عادي</option>
                <option value="2">مدير</option>
              </select>
            </div>
          )}
          
          <div className="form-actions">
            <button className="btn-secondary" onClick={() => setIsModalOpen(false)}>
              إلغاء
            </button>
            <button className="btn-primary" onClick={handleFormSubmit}>
              {editingUser ? 'حفظ التغييرات' : 'إضافة مستخدم'}
            </button>
          </div>
        </div>
      </Modal>
    </div>
  );
};

export default UsersManagement