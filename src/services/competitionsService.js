import axios from 'axios'

const API_BASE = '/api/admin'

export const competitionsService = {
  getAllCompetitions: async (token) => {
    const res = await axios.get(`${API_BASE}/competitions`, {
      headers: { Authorization: `Bearer ${token}` }
    })
    return res.data
  },
  addCompetition: async (data, token) => {
    const res = await axios.post(`${API_BASE}/competitions`, data, {
      headers: { Authorization: `Bearer ${token}` }
    })
    return res.data
  },
  updateCompetition: async (id, data, token) => {
    const res = await axios.put(`${API_BASE}/competitions/${id}`, data, {
      headers: { Authorization: `Bearer ${token}` }
    })
    return res.data
  },
  deleteCompetition: async (id, token) => {
    const res = await axios.delete(`${API_BASE}/competitions/${id}`, {
      headers: { Authorization: `Bearer ${token}` }
    })
    return res.data
  }
}
