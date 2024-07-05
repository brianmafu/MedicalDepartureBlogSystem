
import { Router } from 'express';

import { CreateBlog, GetBlogs, GetBlogById, UpdateBlogById, DeleteBlogById} from '../controllers/blogController';

const router = Router();
router.post('/create', CreateBlog);
router.get('/blogs', GetBlogs);
router.get('/blog/:id', GetBlogById);
router.put('/update/:id', UpdateBlogById);
router.delete('/delete/:id', DeleteBlogById);
export default router;