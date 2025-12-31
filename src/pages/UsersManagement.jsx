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
  const [requests, setRequests] = useState([]);
const [requestsLoading, setRequestsLoading] = useState(false);
const [requestsError, setRequestsError] = useState('');
const [categories, setCategories] = useState([]);
const [acceptModalOpen, setAcceptModalOpen] = useState(false);
const [selectedRequestId, setSelectedRequestId] = useState(null);
const [selectedCategory, setSelectedCategory] = useState('');
  // --- NEW: التبديل بين Tabs ---
const [activeTab, setActiveTab] = useState('users'); // 'users' | 'requests'
const [formData, setFormData] = useState({
  username: '',
  email: '',
  password: '',
  password_confirmation: '',
  age: '',
  gender: 'male',
  points: ''
});
  // --- أعمدة جدول المستخدمين ---
  const userColumns = [
    { key: 'id', title: 'ID' },
    { key: 'username', title: ' Username' },
    { key: 'email', title: 'Email ' },
    { 
      key: 'age', 
      title: 'Age',
      render: (value) => value || 'Not Set'
    },
    { 
      key: 'gender', 
      title: 'Gender',
      render: (value) => ({ male: 'Male', female: 'Female' }[value] || value)
    },
    { 
      key: 'user_type', 
      title: 'User Type',
      render: (value) => value === 1 ? 'Normal User' : 'Admin'
    },
    { key: 'points', title: 'Points' },
    { key: 'purchases_count', title: 'Purchases Count' },
    {
      key: 'actions',
      title: 'Actions',
      render: (_, user) => (
        <div>
          <button className="btn-primary" onClick={() => handleEdit(user)}>Edit</button>
          <button className="btn-danger" onClick={() => handleDelete(user)}>Delete</button>
        </div>
      )
    }
  ];

  const requestsColumns = [
    { key: 'request_id', title: 'Request ID' },
    { key: 'user_id', title: 'User ID' },
    { key: 'title', title: 'Title' },
    { key: 'description', title: 'Description' },
    { key: 'price', title: 'Price' },
    { key: 'book_type', title: 'Book Type' },
    {
      key: 'file_path',
      title: 'File',
      render: (_, request) =>
        request.file_path ? (
          <button
            className="btn-secondary"
            onClick={() => handleDownloadRequest(request.request_id)}
          >
            Download
          </button>
        ) : (
          'No file'
        )
    },
    //{ key: 'file_type', title: 'File Type' },
    //{ key: 'file_size', title: 'File Size', render: (value) => `${(value / 1024).toFixed(2)} KB` },
    { key: 'status', title: 'Status' },
    //{ key: 'created_at', title: 'Created At' },
    {
      key: 'actions',
      title: 'Actions',
      render: (_, request) => (
        request.status === 'pending' && (
          <>
            <button className="btn-primary" onClick={() => openAcceptModal(request.request_id)}>Accept</button>
            <button className="btn-danger" onClick={() => handleRejectRequest(request.request_id)}>Reject</button>
          </>
        )
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
      setErrorMessage('An Error Occured While Fetching User Data');
      setTimeout(() => setErrorMessage(''), 3000);
    } finally {
      setLoading(false);
    }
  };

  const fetchRequests = async () => {
    setRequestsLoading(true);
    try {
      const data = await usersService.getAllRequests(); 
      setRequests(data.requests || []);
      setCategories(data.categories || []);
    } catch (error) {
      console.error('Error fetching requests:', error);
      setRequestsError('An Error Occuerred While Retrieving Book Orders ');
    } finally {
      setRequestsLoading(false);
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
      gender: user.gender || 'male',
      points: user.points || 0
    });
    setIsModalOpen(true);
  };
  
  const handleSaveNewUser = async () => {
    // تحقق واجهة بسيطة قبل الإرسال
    if (!formData.username || !formData.email || !formData.password || !formData.password_confirmation || !formData.age || !formData.gender) {
      alert('   Please Fill In All Requierd Fields (Including Password Confirmation And Age)');
      return;
    }
  
    // تحقق من تساوي الباسوورد
    if (formData.password !== formData.password_confirmation) {
      alert('The Password And Confirmation Do Not Match');
      return;
    }
  
    // تحقق مبدئي لشرط الباكند: طول وكلفة الباسور (تقديري)
    if (formData.password.length < 8) {
      alert(' The Password Must Be At Least 8 Characters Long');
      return;
    }
    // (اختياري) تحقق وجود حرف كبير، حرف صغير، رقم، ورمز
    const pwdRegex = /(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])/;
    if (!pwdRegex.test(formData.password)) {
      alert('  The Password Must Contain a Capital Letter, a Lowercase Letter And a Symbol');
      return;
    }
  
    // تأكد من العمر integer و >=10
    const ageInt = parseInt(formData.age, 10);
    if (isNaN(ageInt) || ageInt < 10) {
      alert('Please Enter An Age Greater Than 10');
      return;
    }
  
    const newUser = {
      username: formData.username,
      email: formData.email,
      password: formData.password,
      password_confirmation: formData.password_confirmation,
      age: ageInt,
      gender: formData.gender,
        points: parseInt(formData.points || 0)

    };
  
    try {
      // **هنا نرسل التوكن أيضاً** (token موجود من useAuth)
      await usersService.addUser(newUser, token);
      alert('The User Was Added Successfully');
      fetchUsers();
      setIsModalOpen(false);
      setFormData({ username: '', email: '', password: '', password_confirmation: '', age: '', gender: 'male' });
    } catch (error) {
      console.error('Error adding user:', error);
      // أفضل استخراج رسالة خطأ من الباك (422 validation)
      const msg = error?.response?.data?.errors ? JSON.stringify(error.response.data.errors) : 'An Error Occured While Adding The User ';
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
          alert('Please Enter Your Password Confirmation');
          return;
        }
        if (userData.password !== userData.password_confirmation) {
          alert('The Password And Confirmation Do Not Match');
          return;
        }
        const pwdRegex = /(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])/;
        if (!pwdRegex.test(userData.password)) {
          alert('The Password Must Contain a Capital Letter, a Lowercase Letter And a Symbol');
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
          alert('Please Enter An Age Greater Than 10');
          return;
        }
        userData.age = ageInt;
      } else {
        alert('Age Field Required');
        return;
      }
      userData.points = parseInt(formData.points || 0);

      // إرسال البيانات للباكند مع التوكن
      await usersService.updateUser(editingUser.id, userData, token);
  
      alert(' User Data Was Successfully Updated');
      setIsModalOpen(false);
      setEditingUser(null);
      fetchUsers();
    } catch (error) {
      console.error('Error updating user:', error);
      setErrorMessage('An Error Occurred While Updating User Data ');
      setTimeout(() => setErrorMessage(''), 3000);
    }
  };
  

  const handleDelete = async (user) => {
    if (window.confirm(`Are You Sure You Deleted The User  "${user.username}"؟`)) {
      try {
        await usersService.deleteUser(user.id, token);
        alert(' The User Was Successfully Deleted');
        fetchUsers();
      } catch (error) {
        console.error('Error deleting user:', error);
        setErrorMessage('An Error Occurred While Deleting The User ');
        setTimeout(() => setErrorMessage(''), 3000);
      }
    }
  };

  const handleFormSubmit = editingUser ? handleSaveUser : handleSaveNewUser;
  const handleRejectRequest = async (requestId) => {
    if (!window.confirm("Are You Sure This Request Will Be Rejected ?")) return;
  
    try {
      const data = await usersService.rejectRequest(requestId);
      alert(data.message);
      // تحديث حالة الطلب في الجدول
      setRequests(prev => prev.map(r => r.request_id === requestId ? { ...r, status: 'rejected' } : r));
    } catch (error) {
      console.error(error);
      alert("An Error Occurred While Rejecting The Request  ");
    }
  };
  
  const handleDownloadRequest = async (requestId) => {
    try {
      const response = await usersService.downloadRequestFile(requestId);
  
      const blob = new Blob([response.data]);
      const url = window.URL.createObjectURL(blob);
  
      const link = document.createElement('a');
      link.href = url;
      link.download = `request_${requestId}.pdf`;
      link.click();
  
      window.URL.revokeObjectURL(url);
    } catch (error) {
      alert("File Upload Failed");
    }
  };
  
  const openAcceptModal = (requestId) => {
    setSelectedRequestId(requestId);  // نخزن ID الطلب
    setSelectedCategory('');           // نعيد تهيئة القسم المختار
    setAcceptModalOpen(true);          // نفتح الـ Modal
  };

    const confirmAcceptRequest = async () => {
    if (!selectedCategory) {
      alert("Please select a category");
      return;
    }
  
    try {
      const data = await usersService.acceptRequest(selectedRequestId, selectedCategory);
      alert(data.message);
      // تحديث حالة الطلب في الجدول
      setRequests(prev => prev.map(r => r.request_id === selectedRequestId ? { ...r, status: 'accepted' } : r));
      setAcceptModalOpen(false);
    } catch (error) {
      console.error(error);
      alert("An Error Occeurred While Connecting To The Server");
    }
  };
  
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
  };

  useEffect(() => {
    if (activeTab === 'requests') {
      fetchRequests();
    }
  }, [activeTab]);

  
  // --- JSX ---
  return (
    <div className="users-management">
      <div className="page-header">
        <h1>Users Management</h1>
        {activeTab === 'users' && (
          <button className="btn-primary" onClick={handleAddUser}>
            Add New User +
          </button>
        )}
      </div>
  
      {/* أزرار التبديل */}
      <div className="buttons-container">
        <button
          className={`btn ${activeTab === 'users' ? 'btn-primary' : 'btn-outline'}`}
          onClick={() => setActiveTab('users')}
        >
         Users Management
        </button>
  
        <button
          className={`btn ${activeTab === 'requests' ? 'btn-primary' : 'btn-outline'}`}
          onClick={() => setActiveTab('requests')}
        >
          Users Requests Management
        </button>
      </div>
  
      {/* ===== USERS TAB ===== */}
      {activeTab === 'users' && (
        <>
          {errorMessage && <div className="error-banner">{errorMessage}</div>}
  
          <div className="user-stats">
            <div className="stat-card">
              <h3>Total Number Of Users</h3>
              <span>{userStats.total}</span>
            </div>
            <div className="stat-card">
              <h3>Number Of Admins</h3>
              <span>{userStats.admin}</span>
            </div>
          </div>
  
          <div className="users-filters">
            <input
              type="text"
              placeholder=" Search For The Users's Name"
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="search-input"
            />
  
            <select
              value={userTypeFilter}
              onChange={(e) => setUserTypeFilter(e.target.value)}
              className="filter-select"
            >
              <option value="all">All users</option>
              <option value="1">Normal User</option>
              <option value="2">Admin</option>
            </select>
  
            <div>Show {filteredUsers.length} Out Of {users.length} Users</div>
          </div>
  
          <DataTable columns={userColumns} data={filteredUsers} loading={loading} />
  
          <Modal
  isOpen={isModalOpen}
  onClose={() => {
    setIsModalOpen(false);
    setEditingUser(null);
  }}
  title={editingUser ? 'Edit User Data' : 'Add New User'}
>
  <div className="user-form">

    <div className="form-group">
      <label>Username</label>
      <input
        type="text"
        value={formData.username}
        onChange={(e) => setFormData({ ...formData, username: e.target.value })}
      />
    </div>

    <div className="form-group">
      <label>Email</label>
      <input
        type="email"
        value={formData.email}
        onChange={(e) => setFormData({ ...formData, email: e.target.value })}
      />
    </div>

    <div className="form-group">
      <label>
        {editingUser
          ? 'Password (Leave empty if unchanged)'
          : 'Password'}
      </label>
      <input
        type="password"
        value={formData.password}
        onChange={(e) =>
          setFormData({ ...formData, password: e.target.value })
        }
      />
    </div>

    <div className="form-group">
      <label>Confirm Password</label>
      <input
        type="password"
        value={formData.password_confirmation}
        onChange={(e) =>
          setFormData({
            ...formData,
            password_confirmation: e.target.value
          })
        }
      />
    </div>

    <div className="form-group">
      <label>Age</label>
      <input
        type="number"
        value={formData.age}
        onChange={(e) =>
          setFormData({ ...formData, age: e.target.value })
        }
      />
    </div>
    <div className="form-group">
  <label>Points</label>
  <input
    type="number"
    min="0"
    value={formData.points}
    onChange={(e) =>
      setFormData({ ...formData, points: e.target.value })
    }
  />
</div>


    <div className="form-group">
      <label>Gender</label>
      <select
        value={formData.gender}
        onChange={(e) =>
          setFormData({ ...formData, gender: e.target.value })
        }
      >
        <option value="male">Male</option>
        <option value="female">Female</option>
      </select>
    </div>

    <div className="form-actions">
      <button
        className="btn-secondary"
        onClick={() => {
          setIsModalOpen(false);
          setEditingUser(null);
        }}
      >
        Cancel
      </button>

      <button
        className="btn-primary"
        onClick={handleFormSubmit}
      >
        {editingUser ? 'Update User' : 'Add User'}
      </button>
    </div>

  </div>
</Modal>

        </>
      )}
  
      {/* ===== REQUESTS TAB ===== */}
      {activeTab === 'requests' && (
        <>
          {requestsError && <div className="error-banner">{requestsError}</div>}
  
          <DataTable
            columns={requestsColumns}
            data={requests}
            loading={requestsLoading}
          />
  
          {/* Modal اختيار القسم */}
          <Modal
            isOpen={acceptModalOpen}
            onClose={() => setAcceptModalOpen(false)}
            title="  Select A Book Category"
          >
            <div className="accept-modal">
              <label>Select A Category:</label>
  
              <select
                value={selectedCategory}
                onChange={(e) => setSelectedCategory(e.target.value)}
              >
                <option value="">-- Select A  Category --</option>
                {categories.map(cat => (
                  <option key={cat.id} value={cat.id}>
                    {cat.name}
                  </option>
                ))}
              </select>
  
              <div className="modal-actions">
                <button
                  className="btn-secondary"
                  onClick={() => setAcceptModalOpen(false)}
                >
                  Cancel
                </button>
  
                <button
                  className="btn-primary"
                  onClick={confirmAcceptRequest}
                >
                  Confirm
                </button>
              </div>
            </div>
          </Modal>
        </>
      )}
    </div>
  );
  
};
export default UsersManagement
