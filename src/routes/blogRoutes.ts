
import { Router } from 'express';

import { CreateBlog, GetBlogs, GetBlogById, UpdateBlogById, DeleteBlog} from '../controllers/blogController.ts';

const router = Router();
router.post('/create', CreateBlog);
router.get('/blogs', GetBlogs);
router.get('/blog/:id', GetBlogById);
router.put('/update/:id', UpdateBlogById);
router.delete('/delete/:id', DeleteBlog);
export default router;