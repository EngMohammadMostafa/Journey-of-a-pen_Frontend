import React, { useState, useEffect } from 'react'
import DataTable from '../components/common/DataTable'
import Modal from '../components/common/Modal'
import { usersService } from '../services/usersService'
import { useAuth } from '../context/AuthContext'
import '../styles/UsersManagement.css'
import '../styles/global.css'

const UsersManagement = () => {
  const { token } = useAuth();

  // --- حالات المستخدمين ---
  const [users, setUsers] = useState([]);
  const [filteredUsers, setFilteredUsers] = useState([]);
  const [loading, setLoading] = useState(false);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingUser, setEditingUser] = useState(null);
  const [searchTerm, setSearchTerm] = useState('');
  const [userTypeFilter, setUserTypeFilter] = useState('all');
  const [errorMessage, setErrorMessage] = useState('');

  const [formData, setFormData] = useState({
    username: '',
    email: '',
    password: '',
    password_confirmation: '',
    age: '',
    gender: 'male'
  });

  // --- أعمدة جدول المستخدمين ---
  const userColumns = [
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
      render: (value) => ({ male: 'ذكر', female: 'أنثى' }[value] || value)
    },
    { 
      key: 'user_type', 
      title: 'نوع المستخدم',
      render: (value) => value === 1 ? 'عادي' : 'مدير'
    },
    { key: 'points', title: 'النقاط' },
    { key: 'purchases_count', title: 'عدد المشتريات' },
    {
      key: 'actions',
      title: 'الإجراءات',
      render: (_, user) => (
        <div>
          <button className="btn-primary" onClick={() => handleEdit(user)}>تعديل</button>
          <button className="btn-danger" onClick={() => handleDelete(user)}>حذف</button>
        </div>
      )
    }
  ];

  // --- دوال إدارة المستخدمين ---
  const fetchUsers = async () => {
    setLoading(true);
    try {
      const response = await usersService.getAllUsers(token);
      setUsers(response.users || []);
      setFilteredUsers(response.users || []);
    } catch (error) {
      console.error('Error fetching users:', error);
      setErrorMessage('حدث خطأ في جلب بيانات المستخدمين');
      setTimeout(() => setErrorMessage(''), 3000);
    } finally {
      setLoading(false);
    }
  };

  const handleAddUser = () => {
    setEditingUser(null);
    setFormData({ username: '', email: '', password: '',password_confirmation: '',age: '', gender: 'male' });
    setIsModalOpen(true);
  };

  const handleEdit = (user) => {
    setEditingUser(user);
    setFormData({
      username: user.username || '',
      email: user.email || '',
      password: '',
      password_confirmation: '',
      age: user.age || '',
      gender: user.gender || 'male'
    });
    setIsModalOpen(true);
  };
  const handleSaveNewUser = async () => {
    // تحقق واجهة بسيطة قبل الإرسال
    if (!formData.username || !formData.email || !formData.password || !formData.password_confirmation || !formData.age || !formData.gender) {
      alert('الرجاء ملء جميع الحقول المطلوبة (بما في ذلك تأكيد كلمة المرور والعمر).');
      return;
    }
  
    // تحقق من تساوي الباسوورد
    if (formData.password !== formData.password_confirmation) {
      alert('كلمة المرور وتأكيدها غير متطابقين.');
      return;
    }
  
    // تحقق مبدئي لشرط الباكند: طول وكلفة الباسور (تقديري)
    if (formData.password.length < 8) {
      alert('كلمة المرور يجب أن تكون على الأقل 8 أحرف.');
      return;
    }
    // (اختياري) تحقق وجود حرف كبير، حرف صغير، رقم، ورمز
    const pwdRegex = /(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])/;
    if (!pwdRegex.test(formData.password)) {
      alert('كلمة المرور يجب أن تحتوي على حرف كبير، حرف صغير، رقم، ورمز خاص.');
      return;
    }
  
    // تأكد من العمر integer و >=10
    const ageInt = parseInt(formData.age, 10);
    if (isNaN(ageInt) || ageInt < 10) {
      alert('الرجاء إدخال عمر صالح (عدد صحيح >= 10).');
      return;
    }
  
    const newUser = {
      username: formData.username,
      email: formData.email,
      password: formData.password,
      password_confirmation: formData.password_confirmation,
      age: ageInt,
      gender: formData.gender
    };
  
    try {
      // **هنا نرسل التوكن أيضاً** (token موجود من useAuth)
      await usersService.addUser(newUser, token);
      alert('تم إضافة المستخدم بنجاح');
      fetchUsers();
      setIsModalOpen(false);
      setFormData({ username: '', email: '', password: '', password_confirmation: '', age: '', gender: 'male' });
    } catch (error) {
      console.error('Error adding user:', error);
      // أفضل استخراج رسالة خطأ من الباك (422 validation)
      const msg = error?.response?.data?.errors ? JSON.stringify(error.response.data.errors) : 'حدث خطأ في إضافة المستخدم';
      setErrorMessage(msg);
      setTimeout(() => setErrorMessage(''), 5000);
    }
  };
  
  const handleSaveUser = async () => {
    try {
      const userData = { ...formData };
  
      // التحقق من كلمة المرور
      if (userData.password) {
        if (!userData.password_confirmation) {
          alert('الرجاء إدخال تأكيد كلمة المرور');
          return;
        }
        if (userData.password !== userData.password_confirmation) {
          alert('كلمة المرور وتأكيدها غير متطابقين.');
          return;
        }
        const pwdRegex = /(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])/;
        if (!pwdRegex.test(userData.password)) {
          alert('كلمة المرور يجب أن تحتوي على حرف كبير، حرف صغير، رقم، ورمز خاص.');
          return;
        }
      } else {
        delete userData.password;
        delete userData.password_confirmation;
      }
  
      // التحقق من العمر
      if (userData.age !== '') {
        const ageInt = parseInt(userData.age, 10);
        if (isNaN(ageInt) || ageInt < 10) {
          alert('الرجاء إدخال عمر صالح (عدد صحيح >= 10).');
          return;
        }
        userData.age = ageInt;
      } else {
        alert('العمر حقل مطلوب.');
        return;
      }
  
      // إرسال البيانات للباكند مع التوكن
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

  const handleFormSubmit = editingUser ? handleSaveUser : handleSaveNewUser;

  // --- useEffect ---
  useEffect(() => {
    fetchUsers();
  }, []);

  useEffect(() => {
    let filtered = users;
    if (searchTerm) {
      filtered = filtered.filter(u => u.username?.toLowerCase().includes(searchTerm.toLowerCase()));
    }
    if (userTypeFilter !== 'all') {
      filtered = filtered.filter(u => u.user_type === parseInt(userTypeFilter));
    }
    setFilteredUsers(filtered);
  }, [users, searchTerm, userTypeFilter]);

  const userStats = {
    total: users.length,
    regular: users.filter(u => u.user_type === 1).length,
    admin: users.filter(u => u.user_type === 2).length,
    withPurchases: users.filter(u => u.purchases_count > 0).length
  };

  
  // --- JSX ---
  return (
    <div className="users-management">
      <div className="page-header">
        <h1>Users Management </h1>
        <button className="btn-primary" onClick={handleAddUser}> Add New User +</button>
      </div>

      {errorMessage && <div className="error-banner">{errorMessage}</div>}

      <div className="user-stats">
        <div className="stat-card"><h3>Total Number Of Users</h3><span>{userStats.total}</span></div>
        <div className="stat-card"><h3>Number Of Admins </h3><span>{userStats.admin}</span></div>
        <div className="stat-card"><h3>المستخدمين الذين لديهم مشتريات</h3><span>{userStats.withPurchases}</span></div>
      </div>

      <div className="users-filters">
        <input
          type="text"
          placeholder=" Search For The Users's Name"
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          className="search-input"
        />
        <select value={userTypeFilter} onChange={(e) => setUserTypeFilter(e.target.value)} className="filter-select">
          <option value="all">All users </option>
          <option value="1"> Normal User</option>
          <option value="2">Admin</option>
        </select>
        <div>Show {filteredUsers.length} Out Of {users.length} Users</div>
      </div>

      <DataTable columns={userColumns} data={filteredUsers} loading={loading} />

      {/* مودال إضافة/تعديل مستخدم */}
      <Modal
        isOpen={isModalOpen}
        onClose={() => { setIsModalOpen(false); setEditingUser(null); }}
        title={editingUser ? 'تعديل بيانات المستخدم' : 'إضافة مستخدم جديد'}
      >
        <div className="user-form">
          <div className="form-group">
            <label>  UserName   * </label>
            <input type="text" value={formData.username} onChange={(e) => setFormData({ ...formData, username: e.target.value })} required />
          </div>
          <div className="form-group">
            <label>Email  *</label>
            <input type="email" value={formData.email} onChange={(e) => setFormData({ ...formData, email: e.target.value })} required />
          </div>
          <div className="form-group">
            <label>{editingUser ? 'كلمة المرور (اتركها فارغة إذا لم تغيرها):' : 'Password  *'}</label>
            <input
              type="password"
              value={formData.password}
              onChange={(e) => setFormData({ ...formData, password: e.target.value })}
              placeholder={editingUser ? "اتركها فارغة للحفاظ على الحالية" : "أدخل كلمة المرور"}
              required={!editingUser}
            />
          </div>
          <div className="form-group">
  <label>
    {editingUser ? 'تأكيد كلمة المرور (اختياري إذا لم تغير كلمة المرور):' : 'Confirm Password *'}
  </label>
  <input
    type="password"
    value={formData.password_confirmation || ''}
    onChange={(e) => setFormData({ ...formData, password_confirmation: e.target.value })}
    placeholder={editingUser ? "اتركها فارغة للحفاظ على كلمة المرور الحالية" : "Enter Password Confirmation"}
    required={!editingUser} // عند إضافة مستخدم جديد مطلوب
  />
</div>

          <div className="form-group">
            <label>Age *</label>
            <input
  type="number"
  name="age"
  value={formData.age}
  onChange={(e) => setFormData({ ...formData, age: e.target.value })}
  min="10"
  max="120"
  required
/>

          </div>
          <div className="form-group">
            <label>Gender</label>
            <select value={formData.gender} onChange={(e) => setFormData({ ...formData, gender: e.target.value })}>
              <option value="male">Male</option>
              <option value="female">Famale</option>
            </select>
          </div>
          <div className="form-actions">
            <button className="btn-secondary" onClick={() => setIsModalOpen(false)}>Cancel</button>
            <button className="btn-primary" onClick={handleFormSubmit}>{editingUser ? 'حفظ التغييرات' : 'Add User '}</button>
          </div>
        </div>
      </Modal>
    </div>
  );
};

export default UsersManagement
