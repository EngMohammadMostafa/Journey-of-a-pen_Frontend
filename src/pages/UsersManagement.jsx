import React, { useState, useEffect } from 'react'
import DataTable from '../components/common/DataTable'
import Modal from '../components/common/Modal'
import { usersService } from '../services/usersService'
import { useAuth } from '../context/AuthContext'
import '../styles/UsersManagement.css'
import '../styles/global.css'


const UsersManagement = () => {
  const [users, setUsers] = useState([]);
  const [filteredUsers, setFilteredUsers] = useState([]);
  const [loading, setLoading] = useState(false);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingUser, setEditingUser] = useState(null);
  const [searchTerm, setSearchTerm] = useState('');
  const [userTypeFilter, setUserTypeFilter] = useState('all');
  const [errorMessage, setErrorMessage] = useState(''); // ✅ إضافة حالة للخطأ
  const { token } = useAuth();

  const [formData, setFormData] = useState({
    username: '',
    email: '',
    password: '',
    age: '',
    gender: 'male'
  });

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

  // ✅ تعديل دالة جلب المستخدمين
  const fetchUsers = async () => {
    setLoading(true);
    try {
      const response = await usersService.getAllUsers(token);
      setUsers(response.users || []);
      setFilteredUsers(response.users || []);
    } catch (error) {
      console.error('Error fetching users:', error);
      setErrorMessage('حدث خطأ في جلب بيانات المستخدمين'); // ✅ تعيين الرسالة
      setTimeout(() => setErrorMessage(''), 3000); // ✅ إخفاؤها بعد 3 ثوانٍ
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchUsers();
  }, []);

  useEffect(() => {
    let filtered = users;
    if (searchTerm) {
      filtered = filtered.filter(user => 
        user.username?.toLowerCase().includes(searchTerm.toLowerCase())
      );
    }
    
    if (userTypeFilter !== 'all') {
      filtered = filtered.filter(user => user.user_type === parseInt(userTypeFilter));
    }
    setFilteredUsers(filtered);
  }, [users, searchTerm, userTypeFilter]);

  const userStats = {
    total: users.length,
    regular: users.filter(u => u.user_type === 1).length,
    admin: users.filter(u => u.user_type === 2).length,
    withPurchases: users.filter(u => u.purchases_count > 0).length
  };

  const handleEdit = (user) => {
    setEditingUser(user);
    setFormData({
      username: user.username || '',
      email: user.email || '',
      password: '',
      age: user.age || '',
      gender: user.gender || 'male'
    });
    setIsModalOpen(true);
  };

  const handleDelete = async (user) => {
    if (window.confirm(`هل أنت متأكد من حذف المستخدم "${user.username}"؟`)) {
      try {
        await usersService.deleteUser(user.id, token);
        alert('تم حذف المستخدم بنجاح');
        fetchUsers();
      } catch (error) {
        console.error('Error deleting user:', error);
        setErrorMessage('حدث خطأ في حذف المستخدم');
        setTimeout(() => setErrorMessage(''), 3000);
      }
    }
  };

  const handleSave = async () => {
    try {
      const userData = { ...formData };
      if (!userData.password) delete userData.password;

      await usersService.updateUser(editingUser.id, userData, token);
      alert('تم تحديث بيانات المستخدم بنجاح');
      setIsModalOpen(false);
      setEditingUser(null);
      fetchUsers();
    } catch (error) {
      console.error('Error updating user:', error);
      setErrorMessage('حدث خطأ في تحديث بيانات المستخدم');
      setTimeout(() => setErrorMessage(''), 3000);
    }
  };

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

  const handleSaveNewUser = async () => {
    try {
      if (!formData.username || !formData.email || !formData.password) {
        alert('الرجاء ملء جميع الحقول المطلوبة');
        return;
      }
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
      setErrorMessage('حدث خطأ في إضافة المستخدم');
      setTimeout(() => setErrorMessage(''), 3000);
    }
  };

  const handleFormSubmit = editingUser ? handleSave : handleSaveNewUser;
  const modalTitle = editingUser ? 'تعديل بيانات المستخدم' : 'إضافة مستخدم جديد';

  return (
    <div className="users-management">
      <div className="page-header">
        <h1>User management</h1>
        <button className="btn-primary" onClick={handleAddUser}>
            Add new user + 
        </button>
      </div>

      {/* ✅ عرض رسالة الخطأ المؤقتة */}
      {errorMessage && (
        <div className="error-banner">
          {errorMessage}
        </div>
      )}

      <div className="user-stats">
        <div className="stat-card">
          <h3>Total number of users</h3>
          <span className="stat-number">{userStats.total}</span>
        </div>
        <div className="stat-card">
          <h3>Numper of managers </h3>
          <span className="stat-number">{userStats.admin}</span>
        </div>
        <div className="stat-card">
          <h3>عدد المستخدمين اللذين لديهم مشتريات</h3>
          <span className="stat-number">{userStats.withPurchases}</span>
        </div>
      </div>

      <div className="users-filters">
        <div className="search-section">
          <input
            type="text"
            placeholder="Search by name "
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
            <option value="all">All users</option>
            <option value="1">Normal users</option>
            <option value="2">Managers</option>
          </select>
        </div>

        <div className="results-count">
          <span>Show {filteredUsers.length} Out of {users.length} Users</span>
        </div>
      </div>

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
