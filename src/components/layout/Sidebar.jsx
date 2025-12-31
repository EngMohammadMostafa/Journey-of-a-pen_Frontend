import React from 'react'
import { Link, useLocation } from 'react-router-dom'
import '../../styles/global.css'

const Sidebar = () => {
  const location = useLocation()

  const menuItems = [
    { path: '/users', icon: '', label: 'Users Management' },
    { path: '/books', icon: '', label: 'Books Management' },
    { path: '/competitions', icon: '', label: 'Competitions Management' },
    { path: '/quotes', icon: '', label: 'Quotes Management' },
    { path: '/notifications', icon: '', label: 'Notifications Management' },
    
  ]

  return (
    <div className="sidebar">
     <div className="sidebar-header-horizontal">
    
    <div className="sidebar-info">
      <h2>ADMIN</h2>
      
    </div>
    <img
      src="../src/assets/loginsmall.jpg"
      alt="User Icon"
      className="sidebar-image-small"
    />
  </div>
      
      <nav className="sidebar-nav">
        <ul>
          {menuItems.map((item) => (
            <li key={item.path}>
              <Link 
                to={item.path} 
                className={`nav-link ${location.pathname === item.path ? 'active' : ''}`}
              >
                <span className="nav-icon">{item.icon}</span>
                <span className="nav-label">{item.label}</span>
              </Link>
            </li>
          ))}
        </ul>
        
      </nav>
      
     
    </div>
  )
}

export default Sidebar